class AdminMailer < ApplicationMailer
  def daily_report
    @new_users = User.where(created_at: Date.yesterday.all_day).order(:email)
    @total_users = User.count
    @submissions_yesterday = Submission.joins(:image_attachment).where(created_at: Date.yesterday.all_day).count
    @total_submissions = Submission.joins(:image_attachment).count

    mail to: "adrien.bretxa@gmail.com", subject: "Daily Sketching — #{Date.yesterday.strftime("%b %-d")} report"
  end
end
