class PoseImage < ApplicationRecord
  THEMES = %w[figures faces hands_feet animals basic_shapes].freeze
  TAGS_BY_THEME = {
    "figures"      => %w[gesture figure],
    "faces"        => %w[portrait caricature],
    "hands_feet"   => %w[hand foot],
    "animals"      => %w[dog cat horse bird wildlife],
    "basic_shapes" => %w[sphere cube cylinder cone]
  }.freeze

  validates :theme, presence: true, inclusion: { in: THEMES }
  validates :path,  presence: true, uniqueness: true

  def tags_array
    tags.to_s.split(",").map(&:strip).reject(&:empty?)
  end

  def tags_array=(arr)
    self.tags = Array(arr).reject(&:empty?).join(",")
  end

  def filename
    File.basename(path)
  end

  def url
    "#{DailyPicker::R2_BASE_URL}/#{path}"
  end
end
