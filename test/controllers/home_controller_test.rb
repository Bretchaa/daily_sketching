require "test_helper"

class HomeControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:alice)
    @challenge = today_challenge
  end

  test "not logged in: shows generic headline and start CTA" do
    get root_path
    assert_response :success
    assert_match "One drawing challenge", response.body
    assert_match "Start today", response.body
  end

  test "logged in, not started: shows welcome back and start CTA" do
    sign_in_as @user
    get root_path
    assert_response :success
    assert_match "Welcome back", response.body
    assert_match "Start today", response.body
  end

  test "logged in, completed but not uploaded: shows well done and upload CTA" do
    sign_in_as @user
    @user.submissions.create!(challenge: @challenge)
    get root_path
    assert_response :success
    assert_match "Well done", response.body
    assert_match "Upload your drawing", response.body
  end

  test "logged in, drew today: shows well done and see drawings CTA" do
    sign_in_as @user
    upload_drawing_for @user, @challenge
    get root_path
    assert_response :success
    assert_match "Well done", response.body
    assert_match "See today", response.body
  end
end
