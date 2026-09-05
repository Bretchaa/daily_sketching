require "test_helper"

class ChallengesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @challenge = today_challenge
  end

  test "GET /today returns 200" do
    get today_challenge_path
    assert_response :success
  end

  test "GET /today with no challenge returns 404" do
    @challenge.destroy
    get today_challenge_path
    assert_response :not_found
  end

  test "GET /today sets challenge_id in session" do
    get today_challenge_path
    assert_equal @challenge.id, session[:challenge_id]
  end
end
