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

  test "logged in, shield covered yesterday and today not done: shows the streak-safe pill" do
    @user.update!(shields_count: 1, restart_shield_granted: true)
    @user.submissions.create!(challenge: challenge_for(Date.current - 3))
    @user.submissions.create!(challenge: challenge_for(Date.current - 2))
    @user.sync_shields! # bridges yesterday
    sign_in_as @user

    get root_path

    assert_response :success
    assert_match "−1 shield", response.body
    assert_match "3 day streak", response.body
  end

  test "logged in, shield covered yesterday but today already drawn: hides the streak-safe pill" do
    @user.update!(shields_count: 1, restart_shield_granted: true)
    @user.submissions.create!(challenge: challenge_for(Date.current - 3))
    @user.submissions.create!(challenge: challenge_for(Date.current - 2))
    @user.sync_shields! # bridges yesterday
    upload_drawing_for @user, @challenge
    sign_in_as @user

    get root_path

    assert_response :success
    refute_match "−1 shield", response.body
  end

  test "logged in, ordinary day with no shield involved: hides the streak-safe pill" do
    @user.submissions.create!(challenge: challenge_for(Date.current - 1))
    sign_in_as @user

    get root_path

    assert_response :success
    refute_match "−1 shield", response.body
  end

  def challenge_for(date)
    Challenge.find_by(date: date) || Challenge.create!(
      date: date,
      theme: "gesture",
      focus: "Focus on gesture",
      tip: "A tip",
      example_image_url: "https://example.com/img.jpg"
    )
  end
end
