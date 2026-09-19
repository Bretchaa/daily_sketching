class DrawingsController < ApplicationController
  CONGRATS_MESSAGES = [
    "You showed up today!",
    "Keep it up!",
    "Nice work today!"
  ].freeze

  def done
    expires_now
    @congrats = CONGRATS_MESSAGES[Date.current.day % CONGRATS_MESSAGES.length]
    session[:return_to] = done_path unless current_user
    @challenge = Challenge.find_by(date: Date.current)
    if @challenge
      if current_user && session[:completed_challenge_id] == @challenge.id
        current_user.submissions.find_or_create_by(challenge: @challenge)
        session.delete(:completed_challenge_id)
      end
      @my_submission = current_user&.submissions&.find_by(challenge: @challenge)
      others = @challenge.submissions.joins(:image_attachment).includes(:user, :cheers).where.not(id: @my_submission&.id).order(created_at: :desc)
      @submissions = [ @my_submission ].compact + others.to_a
      @my_submission&.association(:cheers)&.load_target
      @skipped = params[:skipped].present?
      uploaded = @my_submission&.image&.attached?

      if current_user
        shields_earned = current_user.sync_shields!
        shields_spent = current_user.shields_spent
        if shields_earned.positive? || shields_spent.positive?
          session[:pending_shield_feedback] = {
            "earned" => shields_earned,
            "spent" => shields_spent,
            "date" => Date.current.iso8601
          }
        end
      end

      @streak = current_user ? current_user.streak : 0
      @shields_count = current_user ? current_user.shields_count : 0
      @shield_cap = User::MAX_SHIELDS

      # Only the screens that actually render the shield pill (skipped or
      # uploaded) show a pending grant/spend — the upload-prompt screen never
      # shows it, so it has to wait here instead of being lost the moment it
      # happens. It stays visible for the rest of the day (any refresh today
      # shows it again), but never carries over into a following day.
      feedback = session[:pending_shield_feedback]
      if (uploaded || @skipped) && feedback && feedback["date"] == Date.current.iso8601
        @shields_earned = feedback["earned"].to_i
        @shields_spent = feedback["spent"].to_i
      else
        session.delete(:pending_shield_feedback) if feedback && feedback["date"] != Date.current.iso8601
        @shields_earned = 0
        @shields_spent = 0
      end
      @show_shield_pill = @shields_earned.positive? || @shields_spent.positive?
      submission_ids = @submissions.map(&:id)
      if current_user
        @my_cheers = current_user.cheers.where(submission_id: submission_ids).index_by(&:submission_id)
      else
        @my_cheers = {}
      end
      theme_config = YAML.load_file(Rails.root.join("config", "challenge_themes.yml"))["challenges"]
                         .find { |t| t["theme"] == @challenge.theme }
      @challenge_display_name = theme_config&.dig("display_name") || @challenge.theme.humanize
      unless theme_config&.dig("no_image")
        @practice_theme        = theme_config&.dig("image_theme") || @challenge.theme
        @practice_filter_tag   = theme_config&.dig("filter_tags")&.first
        @practice_display_name = theme_config&.dig("display_name")
      end
    else
      @submissions = []
    end
  end

  def upload_status
    challenge = Challenge.find_by(date: Date.current)
    uploaded = current_user && challenge &&
               current_user.submissions.joins(:image_attachment).exists?(challenge: challenge)
    render json: { uploaded: uploaded }
  end

  def show
    challenge = Challenge.find(session[:challenge_id])
    poses = challenge.poses.order(:position)

    @step = params[:step].to_i
    pose = poses[@step - 1]

    if pose.nil?
      session[:completed_challenge_id] = challenge.id
      redirect_to "/done" and return
    end

    @pose_url = pose.image_url
    @duration_seconds = pose.duration_seconds
    @next_step = @step + 1
    @prev_step = @step > 1 ? @step - 1 : nil
    @show_countdown = @step == 1 && params[:back].blank?
    @total = poses.length

    theme_config = YAML.load_file(Rails.root.join("config", "challenge_themes.yml"))["challenges"]
                       .find { |t| t["theme"] == challenge.theme }
    @flip_image = theme_config&.dig("flip_image") || false
  end
end
