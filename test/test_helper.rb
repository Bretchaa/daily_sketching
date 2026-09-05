ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

OmniAuth.config.test_mode = true

module ActiveSupport
  class TestCase
    parallelize(workers: :number_of_processors)
    fixtures :all

    def today_challenge
      Challenge.find_by(date: Date.current) || Challenge.create!(
        date: Date.current,
        theme: "gesture",
        focus: "Focus on gesture",
        tip: "A tip",
        example_image_url: "https://example.com/img.jpg"
      )
    end

    def sign_in_as(user)
      post sign_in_path, params: { email: user.email, password: "password123" }
    end

    def upload_drawing_for(user, challenge)
      submission = user.submissions.find_or_initialize_by(challenge: challenge)
      submission.image.attach(
        io: File.open(Rails.root.join("test/fixtures/files/drawing.jpg")),
        filename: "drawing.jpg",
        content_type: "image/jpeg"
      )
      submission.save!
      submission
    end
  end
end
