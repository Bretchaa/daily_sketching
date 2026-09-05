require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  # ── Email/password sign in ───────────────────────────────────────────────────

  test "sign in with correct credentials redirects to homepage" do
    post sign_in_path, params: { email: users(:alice).email, password: "password123" }
    assert_redirected_to root_path
  end

  test "sign in from /done redirects back to /done" do
    get done_path
    post sign_in_path, params: { email: users(:alice).email, password: "password123" }
    assert_redirected_to done_path
  end

  test "sign in with wrong password stays on sign in page" do
    post sign_in_path, params: { email: users(:alice).email, password: "wrongpassword" }
    assert_response :unprocessable_entity
  end

  test "sign in with unknown email stays on sign in page" do
    post sign_in_path, params: { email: "nobody@example.com", password: "password123" }
    assert_response :unprocessable_entity
  end

  # ── Sign out ─────────────────────────────────────────────────────────────────

  test "sign out clears session and redirects to homepage" do
    sign_in_as users(:alice)
    delete sign_out_path
    assert_redirected_to root_path
    # Confirm logged out — homepage no longer shows username
    follow_redirect!
    assert_match "One drawing challenge", response.body
  end

  # ── Google OAuth ─────────────────────────────────────────────────────────────

  test "google oauth with new account redirects to pick username" do
    OmniAuth.config.mock_auth[:google_oauth2] = OmniAuth::AuthHash.new(
      provider: "google_oauth2",
      uid: "new-google-uid-999",
      info: { name: "New User", email: "newuser@gmail.com", image: nil }
    )
    Rails.application.env_config["omniauth.auth"] = OmniAuth.config.mock_auth[:google_oauth2]
    get auth_google_oauth2_callback_path
    assert_redirected_to pick_username_path
  end

  test "google oauth with existing account redirects to homepage" do
    # Create a user that already has a username (i.e., not needing username pick)
    existing = User.create!(
      provider: "google_oauth2", uid: "existing-uid-123",
      email: "existing@gmail.com", username: "existing_user", name: "Existing"
    )
    OmniAuth.config.mock_auth[:google_oauth2] = OmniAuth::AuthHash.new(
      provider: "google_oauth2",
      uid: "existing-uid-123",
      info: { name: "Existing", email: "existing@gmail.com", image: nil }
    )
    Rails.application.env_config["omniauth.auth"] = OmniAuth.config.mock_auth[:google_oauth2]
    get auth_google_oauth2_callback_path
    assert_redirected_to root_path
  end

  test "google oauth from /done redirects back to /done" do
    existing = User.create!(
      provider: "google_oauth2", uid: "uid-from-done",
      email: "fromdone@gmail.com", username: "fromdone_user", name: "From Done"
    )
    get done_path  # sets session[:return_to]
    OmniAuth.config.mock_auth[:google_oauth2] = OmniAuth::AuthHash.new(
      provider: "google_oauth2",
      uid: "uid-from-done",
      info: { name: "From Done", email: "fromdone@gmail.com", image: nil }
    )
    Rails.application.env_config["omniauth.auth"] = OmniAuth.config.mock_auth[:google_oauth2]
    get auth_google_oauth2_callback_path
    assert_redirected_to done_path
  end
end
