class DrawingsController < ApplicationController
  def done
    @challenge = Challenge.find_by(date: Date.current)
    if @challenge
      @my_submission = current_user&.submissions&.find_by(challenge: @challenge)
      others = @challenge.submissions.includes(:user).where.not(id: @my_submission&.id).order(created_at: :desc)
      @submissions = [ @my_submission ].compact + others.to_a
    else
      @submissions = []
    end
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
