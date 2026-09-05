class SubmissionsController < ApplicationController
  rate_limit to: 10, within: 1.hour, only: :create

  def show
    @submission = Submission.joins(:image_attachment).find(params[:id])
    @challenge = @submission.challenge
    @user = @submission.user
    today = Challenge.find_by(date: Date.current)
    if current_user && today
      @my_today_submission = current_user.submissions.joins(:image_attachment).find_by(challenge: today)
      @today_challenge = today
    end
  rescue ActiveRecord::RecordNotFound
    redirect_to root_path
  end

  def create
    challenge = Challenge.find_by!(date: Date.current)

    file = params[:image]

    if file.blank?
      return redirect_to done_path, alert: "No image received, please try again."
    end

    if file.size > 20.megabytes
      return redirect_to done_path, alert: "Image is too large. Please upload a file under 20MB."
    end

    unless file.content_type.start_with?("image/")
      return redirect_to done_path, alert: "Only image files are allowed."
    end

    begin
      require "image_processing/vips"
      processed = ImageProcessing::Vips
        .source(file.tempfile)
        .resize_to_limit(2000, 2000)
        .convert("jpeg")
        .saver(quality: 85)
        .call
      attach_io, attach_name, attach_type = processed, "drawing.jpg", "image/jpeg"
    rescue LoadError
      attach_io, attach_name, attach_type = file.tempfile, file.original_filename, file.content_type
    end

    submission = current_user.submissions.find_or_initialize_by(challenge: challenge)
    submission.image.attach(io: attach_io, filename: attach_name, content_type: attach_type)
    submission.note = params[:note].to_s.strip.truncate(200).presence

    if submission.save
      redirect_to done_path
    else
      redirect_to done_path, alert: "Upload failed, please try again."
    end
  rescue ActiveRecord::RecordNotUnique
    redirect_to done_path
  end
end
