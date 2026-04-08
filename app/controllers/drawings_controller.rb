class DrawingsController < ApplicationController
  def done
    @challenge = Challenge.find_by(date: Date.current)
    if @challenge
      @my_submission = current_user&.submissions&.find_by(challenge: @challenge)
      others = @challenge.submissions.includes(:user, :cheers).where.not(id: @my_submission&.id).order(created_at: :desc)
      @submissions = [ @my_submission ].compact + others.to_a
      @my_submission&.association(:cheers)&.load_target
      @streak = current_user ? current_user.streak : 0
      submission_ids = @submissions.map(&:id)
      if current_user
        @my_cheers = current_user.cheers.where(submission_id: submission_ids).index_by(&:submission_id)
      else
        @my_cheers = {}
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

    redirect_to "/done" and return if pose.nil?

    @pose_url = pose.image_url
    @duration_seconds = pose.duration_seconds
    @next_step = @step + 1
    @prev_step = @step > 1 ? @step - 1 : nil
    @total = poses.length
  end
end
