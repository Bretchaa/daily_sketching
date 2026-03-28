require "zlib"

class DailyPicker
  R2_BASE_URL = "https://assets.dailysketching.app"
  MANIFEST_PATH = Rails.root.join("config", "image_manifest.json")

  def initialize(theme:, date: Date.current, poses_count: 5)
    @theme = theme
    @date = date
    @poses_count = poses_count
  end

  def poses
    manifest = JSON.parse(File.read(MANIFEST_PATH))
    files = manifest.dig(@theme, "poses") || []
    raise "No pose images found for theme=#{@theme}" if files.empty?

    seeded_shuffle(files).first(@poses_count).map { |path| "#{R2_BASE_URL}/#{path}" }
  end

  private

  def seeded_shuffle(array)
    seed = "#{@theme}-#{@date.iso8601}"
    rng = Random.new(Zlib.crc32(seed))
    array.shuffle(random: rng)
  end
end
