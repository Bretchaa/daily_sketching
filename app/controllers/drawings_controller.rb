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
      @streak = current_user ? current_user.streak : 0
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
