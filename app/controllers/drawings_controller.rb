class DrawingsController < ApplicationController
  def show
    challenge = Challenge.find(session[:challenge_id])
    poses = challenge.poses.order(:position)

    @step = params[:step].to_i
    pose = poses[@step - 1]

    redirect_to "/done" and return if pose.nil?

    @pose_url = pose.image_url
    @duration_seconds = pose.duration_seconds
    @next_step = @step + 1
    @total = poses.length
  end
end