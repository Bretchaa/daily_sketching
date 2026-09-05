namespace :emails do
  desc "Send all scheduled emails (runs daily at 9am)"
  task send_scheduled: :environment do
    yesterday = Date.current - 1
    today = Date.current

    # ── Email 1: D+1 followup after first challenge ──────────────────────────
    # Users whose very first submission was yesterday, not yet sent
    yesterday_challenge = Challenge.find_by(date: yesterday)
    today_challenge     = Challenge.find_by(date: today)

    if yesterday_challenge
      candidates = User.where(email_notifications: true, first_followup_sent_at: nil)

      candidates.each do |user|
        completed = user.submissions.joins(:image_attachment)
        next unless completed.exists?(challenge: yesterday_challenge)  # drew yesterday
        next unless completed.count == 1                                # yesterday was their first ever

        # Skip if they already drew today
        next if today_challenge && completed.exists?(challenge: today_challenge)

        begin
          UserMailer.first_challenge_followup(user).deliver_now
          user.update_columns(first_followup_sent_at: Time.current)
          Rails.logger.info "first_challenge_followup sent to #{user.email}"
        rescue => e
          Rails.logger.error "first_challenge_followup failed for #{user.email}: #{e.message}"
        end
      end
    end

    # ── Email 2: 24h nudge for users who never started ───────────────────────
    # Signed up 23-25h ago, zero completed submissions
    nudge_candidates = User.where(email_notifications: true)
                           .where(created_at: 25.hours.ago..23.hours.ago)
                           .where.not(id: Submission.joins(:image_attachment).select(:user_id))

    nudge_candidates.each do |user|
      begin
        UserMailer.first_challenge_nudge(user).deliver_now
        Rails.logger.info "first_challenge_nudge sent to #{user.email}"
      rescue => e
        Rails.logger.error "first_challenge_nudge failed for #{user.email}: #{e.message}"
      end
    end

    # ── Email 3: 7-day reengagement ──────────────────────────────────────────
    # Last draw was 7-8 days ago — catches one-timers and streak breakers who didn't return
    reengagement_candidates = User.where(email_notifications: true)
                                  .where("reengagement_sent_at IS NULL OR reengagement_sent_at < ?", 30.days.ago)

    reengagement_candidates.each do |user|
      completed = user.submissions.joins(:image_attachment)
      next if completed.none?

      last_draw = completed.joins(:challenge).maximum("challenges.date")
      next unless last_draw
      next unless last_draw.to_date.between?(8.days.ago.to_date, 7.days.ago.to_date)

      begin
        UserMailer.reengagement(user).deliver_now
        user.update_columns(reengagement_sent_at: Time.current)
        Rails.logger.info "reengagement sent to #{user.email}"
      rescue => e
        Rails.logger.error "reengagement failed for #{user.email}: #{e.message}"
      end
    end

    # ── Email 4: Streak break recovery ────────────────────────────────────────
    # User missed exactly yesterday (last draw = 2 days ago), had a streak of 2+
    # Not emailed for a streak break in the last 30 days
    streak_break_candidates = User.where(email_notifications: true)
                                  .where("streak_break_sent_at IS NULL OR streak_break_sent_at < ?", 30.days.ago)

    streak_break_candidates.each do |user|
      completed = user.submissions.joins(:image_attachment)
      next if completed.count < 2

      last_draw = completed.joins(:challenge).maximum("challenges.date")
      next unless last_draw
      next unless last_draw.to_date == 2.days.ago.to_date  # missed exactly yesterday

      # Calculate streak length before the break
      streak_length = 0
      check_date = 2.days.ago.to_date
      loop do
        break unless completed.joins(:challenge).where(challenges: { date: check_date }).exists?
        streak_length += 1
        check_date -= 1
      end
      next if streak_length < 2  # single draw doesn't count as a streak

      begin
        UserMailer.streak_break(user, streak_length).deliver_now
        user.update_columns(streak_break_sent_at: Time.current)
        Rails.logger.info "streak_break sent to #{user.email} (streak: #{streak_length})"
      rescue => e
        Rails.logger.error "streak_break failed for #{user.email}: #{e.message}"
      end
    end

    Rails.logger.info "emails:send_scheduled completed at #{Time.current}"
  end
end
