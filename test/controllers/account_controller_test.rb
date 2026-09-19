require "test_helper"

class AccountControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:alice)
  end

  test "profile page shows the streak shield stat at 0/2 when the user has none" do
    sign_in_as @user
    get account_path
    assert_response :success
    assert_match "streak shield", response.body
    assert_match(/0<span[^>]*>\/2/, response.body)
    assert_match "#14B8A6", response.body
  end

  test "profile page shows the streak shield count as a fraction of the cap" do
    @user.update!(shields_count: 2)
    sign_in_as @user

    get account_path

    assert_response :success
    assert_match(/2<span[^>]*>\/2/, response.body)
    assert_match "#14B8A6", response.body
  end

  # ── Empty state ──────────────────────────────────────────────────────────────

  test "empty profile with today's challenge not started shows a start-challenge CTA" do
    sign_in_as @user

    get account_path

    assert_response :success
    assert_match "Start today&#39;s challenge", response.body
    refute_match "Upload to unlock", response.body
  end

  test "empty profile with today's challenge finished but not uploaded shows an upload CTA" do
    challenge = today_challenge
    @user.submissions.create!(challenge: challenge) # completed the draw session, no image
    sign_in_as @user

    get account_path

    assert_response :success
    assert_match "Upload to unlock", response.body
    refute_match "Start today&#39;s challenge", response.body
  end

  test "profile with an older uploaded drawing shows the normal gallery, no CTA, even if today isn't uploaded" do
    old_challenge = Challenge.create!(
      date: Date.current - 5,
      theme: "gesture",
      focus: "Focus on gesture",
      tip: "A tip",
      example_image_url: "https://example.com/img.jpg"
    )
    upload_drawing_for @user, old_challenge
    sign_in_as @user

    get account_path

    assert_response :success
    refute_match "Upload to unlock", response.body
    refute_match "Start today&#39;s challenge", response.body
  end

  # ── Nav bar streak icon color ────────────────────────────────────────────────
  #
  # The nav icon's glow uses distinct alpha values (0.6) from every other bolt
  # on the page (e.g. the profile's own day-streak stat glows at 0.5), so
  # these strings uniquely identify the top-right nav icon specifically.
  NAV_TURQUOISE_GLOW = "drop-shadow(0 1px 4px rgba(20,184,166,0.6))".freeze
  NAV_YELLOW_GLOW = "drop-shadow(0 1px 4px rgba(255,212,0,0.6))".freeze

  test "nav streak icon turns turquoise the day after a shield bridged a gap" do
    @user.update!(shields_count: 1, restart_shield_granted: true)
    @user.submissions.create!(challenge: challenge_for(Date.current - 3))
    @user.submissions.create!(challenge: challenge_for(Date.current - 2))
    @user.sync_shields! # bridges yesterday
    sign_in_as @user

    get account_path

    assert_response :success
    assert_match NAV_TURQUOISE_GLOW, response.body
    refute_match NAV_YELLOW_GLOW, response.body
  end

  test "nav streak icon is back to yellow once today is drawn" do
    @user.update!(shields_count: 1, restart_shield_granted: true)
    @user.submissions.create!(challenge: challenge_for(Date.current - 3))
    @user.submissions.create!(challenge: challenge_for(Date.current - 2))
    @user.sync_shields! # bridges yesterday
    @user.submissions.create!(challenge: today_challenge)
    sign_in_as @user

    get account_path

    assert_response :success
    assert_match NAV_YELLOW_GLOW, response.body
    refute_match NAV_TURQUOISE_GLOW, response.body
  end

  test "nav streak icon is yellow on an ordinary day with no shield involved" do
    @user.submissions.create!(challenge: challenge_for(Date.current - 1))
    @user.submissions.create!(challenge: today_challenge)
    sign_in_as @user

    get account_path

    assert_response :success
    assert_match NAV_YELLOW_GLOW, response.body
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
