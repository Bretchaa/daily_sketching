require "test_helper"
require "rake"

class ChallengesRakeTest < ActiveSupport::TestCase
  setup do
    Rails.application.load_tasks if Rake::Task.tasks.empty?
    Rake::Task["challenges:replace_paused"].reenable
    Rake::Task["challenges:generate"].reenable
  end

  test "replace_paused swaps unstarted still-life days and keeps started ones" do
    unstarted = Challenge.create!(date: Date.current + 3, theme: "still_life", focus: "f", tip: "t")
    started = Challenge.create!(date: Date.current, theme: "still_life", focus: "f", tip: "t")
    started.poses.create!(image_url: "https://example.com/p.jpg", duration_seconds: 300, position: 1)

    assert_output(/Removing #{unstarted.date} — still_life/) do
      Rake::Task["challenges:replace_paused"].invoke
    end

    refute Challenge.exists?(unstarted.id)
    replacement = Challenge.find_by(date: unstarted.date)
    assert replacement
    refute_equal "still_life", replacement.theme
    assert_equal "still_life", started.reload.theme
  end

  test "generate never schedules a paused theme" do
    assert_output(/Done!/) { Rake::Task["challenges:generate"].invoke("60") }
    refute Challenge.where("date >= ?", Date.current).exists?(theme: "still_life")
  end
end
