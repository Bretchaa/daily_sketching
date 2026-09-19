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
end
