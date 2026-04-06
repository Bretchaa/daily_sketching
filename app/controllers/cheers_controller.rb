class CheersController < ApplicationController
  rate_limit to: 30, within: 1.minute, only: :create

  def create
    unless current_user
      redirect_to sign_in_path, alert: "Sign in to cheer drawings"
      return
    end

    submission = Submission.find(params[:submission_id])
    cheer = current_user.cheers.find_or_initialize_by(submission: submission)

    if cheer.count < Cheer::MAX_PER_USER
      cheer.count += 1
      cheer.save!
    end

    redirect_to done_path
  end
end
