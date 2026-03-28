class UploadsController < ApplicationController
  before_action :set_user_from_token

  def show
    @challenge = Challenge.find_by(date: Date.current)
    @existing = @user.submissions.find_by(challenge: @challenge)
  end

  def create
    challenge = Challenge.find_by!(date: Date.current)
    submission = @user.submissions.find_or_initialize_by(challenge: challenge)
    submission.image = params[:image]

    if submission.save
      redirect_to upload_path(token: params[:token]), notice: "Drawing uploaded!"
    else
      redirect_to upload_path(token: params[:token]), alert: "Upload failed, please try again."
    end
  end

  private

  def set_user_from_token
    @user = User.find_by(upload_token: params[:token])
    redirect_to root_path if @user.nil?
  end
end
