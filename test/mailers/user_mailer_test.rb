require "test_helper"

class UserMailerTest < ActionMailer::TestCase
  test "password_reset" do
    user = User.new(email: "test@example.com", username: "testuser", reset_password_token: "abc123", reset_password_sent_at: Time.current)
    mail = UserMailer.password_reset(user)
    assert_equal "Reset your Daily Sketching password", mail.subject
    assert_equal [ "test@example.com" ], mail.to
  end
end
