require "test_helper"

class RegistrationsControllerTest < ActionDispatch::IntegrationTest
  # ── Email/password sign up ───────────────────────────────────────────────────

  test "sign up with valid details creates account and redirects to homepage" do
    post sign_up_path, params: { username: "newuser", email: "new@test.com", password: "password123" }
    assert_redirected_to root_path
    assert User.exists?(email: "new@test.com")
  end

  test "sign up from /done redirects back to /done" do
    post sign_up_path, params: {
      username: "newuser2", email: "new2@test.com", password: "password123",
      return_to: done_path
    }
    assert_redirected_to done_path
  end

  test "sign up with duplicate email shows error" do
    post sign_up_path, params: { username: "other", email: users(:alice).email, password: "password123" }
    assert_response :unprocessable_entity
  end

  test "sign up with short password shows error" do
    post sign_up_path, params: { username: "newuser3", email: "new3@test.com", password: "abc" }
    assert_response :unprocessable_entity
  end

  test "sign up with blank username shows error" do
    post sign_up_path, params: { username: "", email: "new4@test.com", password: "password123" }
    assert_response :unprocessable_entity
  end
end
