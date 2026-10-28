require "test_helper"

class PracticeControllerTest < ActionDispatch::IntegrationTest
  test "practice page hides categories whose photos are all hidden" do
    PoseImage.create!(theme: "basic_shapes", path: "poses/basic_shapes/Reference-Pictures_Basic-Forms-001.jpg")

    get practice_path

    assert_response :success
    assert_match "Figure Drawing", response.body
    refute_match "Basic Shapes", response.body
  end
end
