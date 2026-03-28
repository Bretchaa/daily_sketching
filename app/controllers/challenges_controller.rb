class ChallengesController < ApplicationController
  def today
    @challenge = Challenge.find_by!(date: Date.current)

    if @challenge.poses.empty?
      poses_count = 5
      picker = DailyPicker.new(theme: @challenge.theme, date: @challenge.date, poses_count: poses_count)

      duration = (@challenge.theme == "long_poses") ? 300 : 60

      picker.poses.each_with_index do |url, idx|
        @challenge.poses.create!(
          image_url: url,
          duration_seconds: duration,
          position: idx + 1
        )
      end
    end

    session[:challenge_id] = @challenge.id
  end
end
