class GalleryController < ApplicationController
  def preview
    # Mix of portrait and landscape example images for masonry testing
    @preview_images = [
      { url: "https://assets.dailysketching.app/examples/gesture_warmup/example_v2.jpeg", username: "marie" },
      { url: "https://assets.dailysketching.app/examples/portrait_study/example.jpeg", username: "thomas" },
      { url: "https://assets.dailysketching.app/examples/hands_feet/example.jpeg", username: "sofia" },
      { url: "https://assets.dailysketching.app/examples/still_life/example.jpeg", username: "lucas" },
      { url: "https://assets.dailysketching.app/examples/caricature/example_v2.jpeg", username: "anna" },
      { url: "https://assets.dailysketching.app/examples/box_figure/example_v3.jpeg", username: "pierre" },
      { url: "https://assets.dailysketching.app/examples/robo_bean/example_v4.png", username: "camille" },
      { url: "https://assets.dailysketching.app/examples/figure_study/example_v2.jpeg", username: "julien" },
    ]
  end

  def show
    date = Date.parse(params[:date]) rescue Date.yesterday
    @challenge = Challenge.find_by!(date: date)
    all = @challenge.submissions.includes(:user, image_attachment: :blob)
                    .select { |s| s.image.attached? }
    my = current_user ? all.find { |s| s.user_id == current_user.id } : nil
    @submissions = ([ my ] + all.reject { |s| s == my }).compact
    @date = date
    @my_cheers = current_user ? current_user.cheers.where(submission: @submissions).index_by(&:submission_id) : {}
  end
end
