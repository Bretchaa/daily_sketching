require "test_helper"

class DrawingsControllerTest < ActionDispatch::IntegrationTest
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
end
