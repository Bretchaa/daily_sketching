require "clockwork"
require_relative "boot"
require_relative "environment"

require "rake"
Rails.application.load_tasks

module Clockwork
  every(1.day, "emails.send_scheduled", at: "09:00", tz: "Europe/Paris") do
    Rails.logger.info "[clockwork] Running emails:send_scheduled"
    Rake::Task["emails:send_scheduled"].invoke
    Rake::Task["emails:send_scheduled"].reenable
  end

  every(1.day, "challenges.generate", at: "00:01", tz: "Europe/Paris") do
    Rails.logger.info "[clockwork] Running challenges:generate"
    Rake::Task["challenges:generate"].invoke
    Rake::Task["challenges:generate"].reenable
  end
end
