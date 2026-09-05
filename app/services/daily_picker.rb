require "zlib"

class DailyPicker
  R2_BASE_URL = "https://assets.dailysketching.app"

  def initialize(theme:, date: Date.current, poses_count: 5, filter_tags: nil, pool_themes: nil)
    @theme = theme
    @date = date
    @poses_count = poses_count
    @filter_tags = filter_tags
    @pool_themes = pool_themes || [ theme ]
  end

  def poses
    scope = PoseImage.where(theme: @theme)
    records = @filter_tags.present? ? scope.select { |p| (p.tags_array & @filter_tags).any? } : scope.to_a
    raise "No pose images found for theme=#{@theme}" if records.empty?

    paths = seeded_shuffle(records.map(&:path)).first(@poses_count)
    paths.map { |path| "#{R2_BASE_URL}/#{path}" }
  end

  private

  def seeded_shuffle(array)
    # Shuffle once using a theme-only seed — this fixed order never changes
    rng = Random.new(Zlib.crc32(@theme))
    master = array.sort.shuffle(random: rng)

    # Advance by poses_count each time this image pool has been used before
    # (pool_themes covers every challenge type that draws from this same pool)
    previous_uses = Challenge.where(theme: @pool_themes).where("date < ?", @date).count
    offset = (previous_uses * @poses_count) % master.length

    master.rotate(offset)
  end
end
