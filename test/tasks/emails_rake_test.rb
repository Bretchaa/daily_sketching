require "test_helper"
require "rake"

class EmailsRakeTest < ActiveSupport::TestCase
  include ActionMailer::TestHelper

  setup do
    Rails.application.load_tasks if Rake::Task.tasks.empty?
    Rake::Task["emails:send_scheduled"].reenable
    @user = users(:alice)
    @user.update!(unsubscribe_token: "test-token") # set on signup; fixtures skip callbacks
    users(:bob).update!(email_notifications: false)
  end

  test "no 'a week without drawing' email when the user finished yesterday's session without uploading" do
    upload_drawing_for(@user, challenge_on(7.days.ago))
    @user.submissions.create!(challenge: challenge_on(1.day.ago)) # finished, skipped the upload

    assert_no_emails { send_scheduled }
  end

  test "'a week without drawing' email when the last finished session was 7 days ago, even without an upload" do
    @user.submissions.create!(challenge: challenge_on(7.days.ago))

    assert_emails(1) { send_scheduled }
    assert_equal "7 days without drawing. Let's fix that", ActionMailer::Base.deliveries.last.subject
  end

  test "streak break email counts finished sessions without uploads in the streak" do
    @user.submissions.create!(challenge: challenge_on(3.days.ago))
    @user.submissions.create!(challenge: challenge_on(2.days.ago))
    @user.update!(shields_count: 0)

    assert_emails(1) { send_scheduled }
    assert_equal "It's all good, come draw with us today", ActionMailer::Base.deliveries.last.subject
  end

  test "no 'first challenge is waiting' nudge when the new user finished a session but skipped the upload" do
    @user.update!(created_at: 24.hours.ago)
    @user.submissions.create!(challenge: challenge_on(Time.current))

    assert_no_emails { send_scheduled }
  end

  test "'first challenge is waiting' nudge when the new user never finished a session" do
    @user.update!(created_at: 24.hours.ago)

    assert_emails(1) { send_scheduled }
    assert_equal "Your first challenge is waiting", ActionMailer::Base.deliveries.last.subject
  end

  private

  def send_scheduled
    Rake::Task["emails:send_scheduled"].invoke
  end

  def challenge_on(time)
    date = time.to_date
    Challenge.find_by(date: date) || Challenge.create!(date: date, theme: "gesture_warmup", focus: "f", tip: "t")
  end
end
