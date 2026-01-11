require "zlib"

class DailyPicker
  IMAGE_GLOB = "*.{jpg,jpeg,png,webp}"

  def initialize(theme:, date: Date.current, poses_count: 5)
    @theme = theme
    @date = date
    @poses_count = poses_count
  end

  def poses
    files = Dir.glob(Rails.root.join("public", "poses", @theme, IMAGE_GLOB)).sort
    raise "No pose images found for theme=#{@theme}" if files.empty?

    seeded_shuffle(files).first(@poses_count).map { |path| to_public_url(path) }
  end

  private

  def seeded_shuffle(array)
    seed = "#{@theme}-#{@date.iso8601}"
    rng = Random.new(Zlib.crc32(seed))
    array.shuffle(random: rng)
  end

  def to_public_url(path)
    path.to_s.sub(Rails.root.join("public").to_s, "")
  end
end
