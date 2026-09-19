require "test_helper"

class DrawingsControllerTest < ActionDispatch::IntegrationTest
  include ActiveSupport::Testing::TimeHelpers

  setup do
    @user = users(:alice)
    @challenge = today_challenge
    @poses = 3.times.map do |i|
      @challenge.poses.create!(
        image_url: "https://example.com/pose#{i + 1}.jpg",
        duration_seconds: 30,
        position: i + 1
      )
    end
  end

  def start_session
    get today_challenge_path
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

  # ── /done page states ────────────────────────────────────────────────────────

  test "not logged in: shows sign-in screen" do
    get done_path
    assert_response :success
    assert_match "Continue with Google", response.body
  end

  test "logged in, no upload: shows upload step" do
    sign_in_as @user
    get done_path
    assert_response :success
    assert_match "Complete your challenge", response.body
  end

  test "logged in, skipped: shows locked gallery with unlock CTA" do
    sign_in_as @user
    get done_path(skipped: "1")
    assert_response :success
    assert_match "Upload to unlock", response.body
    assert_match(/You showed up today|Keep it up|Nice work today/, response.body)
  end

  test "logged in, uploaded: shows success screen" do
    sign_in_as @user
    upload_drawing_for @user, @challenge
    get done_path
    assert_response :success
    assert_match(/You showed up today|Keep it up|Nice work today/, response.body)
    refute_match "Complete your challenge", response.body
  end

  test "logged in, skipped then uploaded: shows success screen" do
    sign_in_as @user
    get done_path(skipped: "1")
    upload_drawing_for @user, @challenge
    get done_path
    assert_response :success
    assert_match(/You showed up today|Keep it up|Nice work today/, response.body)
  end

  test "visiting /done while logged out stores return_to in session" do
    get done_path
    assert_equal done_path, session[:return_to]
  end

  # ── Drawing session: step rendering ─────────────────────────────────────────

  test "GET /draw/1 renders successfully" do
    start_session
    get draw_path(step: 1)
    assert_response :success
  end

  test "GET /draw/1 shows countdown overlay" do
    start_session
    get draw_path(step: 1)
    assert_match "countdown-overlay", response.body
    assert_match "countdown-number", response.body
  end

  test "GET /draw/1 countdown shows mascot and sentence" do
    start_session
    get draw_path(step: 1)
    assert_match "drawing_mascotte", response.body
    assert_match "Grab a sheet of paper", response.body
  end

  test "GET /draw/1 countdown JS does not reference removed label element" do
    start_session
    get draw_path(step: 1)
    refute_match "countdown-label", response.body
    refute_match "label.textContent", response.body
  end

  test "GET /draw/2 does not show countdown" do
    start_session
    get draw_path(step: 2)
    assert_response :success
    refute_match "countdown-overlay", response.body
  end

  test "GET /draw/1 with back param does not show countdown" do
    start_session
    get draw_path(step: 1, back: true)
    assert_response :success
    refute_match "countdown-overlay", response.body
  end

  test "GET /draw/1 shows correct pose counter" do
    start_session
    get draw_path(step: 1)
    assert_match "1 / #{@poses.length}", response.body
  end

  test "GET /draw/2 shows correct pose counter" do
    start_session
    get draw_path(step: 2)
    assert_match "2 / #{@poses.length}", response.body
  end

  # ── Drawing session: session completion ──────────────────────────────────────

  test "step beyond last pose redirects to done" do
    start_session
    get draw_path(step: @poses.length + 1)
    assert_redirected_to "/done"
  end

  test "completing last step sets completed_challenge_id in session" do
    start_session
    get draw_path(step: @poses.length + 1)
    assert_equal @challenge.id, session[:completed_challenge_id]
  end

  test "visiting done after completing sets submission and clears session flag" do
    sign_in_as @user
    start_session
    get draw_path(step: @poses.length + 1)
    get done_path
    assert_response :success
    assert @user.submissions.exists?(challenge: @challenge)
    assert_nil session[:completed_challenge_id]
  end

  # ── Streak shield feedback ───────────────────────────────────────────────────

  test "finishing without uploading, then skipping, still shows the earned-shield banner" do
    sign_in_as @user
    start_session
    get draw_path(step: @poses.length + 1)

    get done_path # STEP 1: upload prompt — earns the shield, but can't display it
    refute_match "streak shield", response.body

    get done_path(skipped: "1") # click "Skip for now" — first screen that CAN show it

    assert_response :success
    assert_match "+1 shield", response.body
  end

  test "reloading the skipped screen again keeps showing the earned-shield banner for the rest of the day" do
    sign_in_as @user
    start_session
    get draw_path(step: @poses.length + 1)
    get done_path
    get done_path(skipped: "1")

    get done_path(skipped: "1")

    assert_response :success
    assert_match "+1 shield", response.body
  end

  test "completing your very first challenge shows the earned-shield banner and count" do
    sign_in_as @user
    upload_drawing_for @user, @challenge

    get done_path

    assert_response :success
    assert_match "+1 shield", response.body
  end

  test "reloading done after completing keeps showing the earned-shield banner for the rest of the day" do
    sign_in_as @user
    upload_drawing_for @user, @challenge
    get done_path

    get done_path

    assert_response :success
    assert_match "+1 shield", response.body
  end

  test "the earned-shield banner does not carry over into the next day" do
    sign_in_as @user
    upload_drawing_for @user, @challenge
    get done_path
    assert_match "+1 shield", response.body

    tomorrow = Date.current + 1
    tomorrow_challenge = challenge_for(tomorrow)
    travel_to(tomorrow) do
      upload_drawing_for @user, tomorrow_challenge
      get done_path
      assert_response :success
      refute_match "+1 shield", response.body
    end
  end

  test "an ordinary day with no shield activity does not show the shield pill" do
    @user.update!(restart_shield_granted: true, shields_count: 1)
    sign_in_as @user
    upload_drawing_for @user, @challenge

    get done_path

    assert_response :success
    refute_match "+1 shield", response.body
    refute_match "streak shield", response.body
  end

  test "a day that gets bridged by a shield shows the saved-streak pill and message" do
    @user.update!(restart_shield_granted: true, shields_count: 1)
    upload_drawing_for @user, challenge_for(Date.current - 2) # yesterday was missed
    sign_in_as @user

    upload_drawing_for @user, @challenge

    get done_path

    assert_response :success
    assert_match "A streak shield saved your streak!", response.body
  end
end
