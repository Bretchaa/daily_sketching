require "test_helper"

class SubmissionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:alice)
    @challenge = today_challenge
    sign_in_as @user
  end

  test "uploading without an image redirects back with alert" do
    post submissions_path, params: {}
    assert_redirected_to done_path
    assert_equal "No image received, please try again.", flash[:alert]
  end

  test "uploading a non-image file redirects back with alert" do
    file = fixture_file_upload("drawing.jpg", "text/plain")
    post submissions_path, params: { image: file }
    assert_redirected_to done_path
    assert_equal "Only image files are allowed.", flash[:alert]
  end

  test "uploading when not logged in does not create a submission" do
    get sign_out_path
    post submissions_path, params: {}
    assert_equal 0, Submission.count
  end

  # These tests require libvips — skipped if not installed locally
  test "uploading a valid image saves submission and redirects to done" do
    skip "libvips not installed" unless vips_available?
    image = fixture_file_upload("drawing.jpg", "image/jpeg")
    post submissions_path, params: { image: image }
    assert_redirected_to done_path
    assert @user.submissions.joins(:image_attachment).exists?(challenge: @challenge)
  end

  test "uploading twice replaces the existing submission" do
    skip "libvips not installed" unless vips_available?
    image = fixture_file_upload("drawing.jpg", "image/jpeg")
    post submissions_path, params: { image: image }
    post submissions_path, params: { image: image }
    assert_equal 1, @user.submissions.where(challenge: @challenge).count
  end

  private

  def vips_available?
    require "image_processing/vips"
    true
  rescue LoadError
    false
  end
end
