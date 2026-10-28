require "test_helper"

class DailyPickerTest < ActiveSupport::TestCase
  setup do
    PoseImage.delete_all
    3.times { |i| PoseImage.create!(theme: "figures", path: "poses/figures/pose_#{i}.jpg") }
    3.times { |i| PoseImage.create!(theme: "figures", path: "poses/figures/Reference-Pictures_Figure-#{i}.jpg") }
  end

  test "hidden Reference.Pictures photos are never picked" do
    urls = DailyPicker.new(theme: "figures", poses_count: 3).poses

    assert_equal 3, urls.size
    assert urls.none? { |u| u.include?("Reference_pictures") }
  end

  test "repeats visible poses rather than leaving gaps when the pool is too small" do
    urls = DailyPicker.new(theme: "figures", poses_count: 5).poses

    assert_equal 5, urls.size
    assert urls.none? { |u| u.include?("Reference_pictures") }
  end

  test "hidden? matches a file or folder starting with the prefix, regardless of case" do
    assert PoseImage.new(path: "poses/basic_shapes/Reference-Pictures_Fundamentals_Basic-Forms-002.jpg").hidden?
    assert PoseImage.new(path: "poses/faces/reference_pictures_9.jpg").hidden?
    assert PoseImage.new(path: "poses/Reference_pictures/pose.jpg").hidden?
    refute PoseImage.new(path: "poses/figures/my_reference_pictures.jpg").hidden?
  end
end
