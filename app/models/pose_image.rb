class PoseImage < ApplicationRecord
  THEMES = %w[figures faces hands_feet animals basic_shapes].freeze
  TAGS_BY_THEME = {
    "figures"      => %w[gesture figure],
    "faces"        => %w[portrait caricature],
    "hands_feet"   => %w[hand foot],
    "animals"      => %w[dog cat horse bird wildlife],
    "basic_shapes" => %w[sphere cube cylinder cone]
  }.freeze

  # Kept out of daily challenges and practice while we wait for a license reply from
  # Reference.Pictures (Oct 2026). They stay in the backstage library; empty this list to restore them.
  # Compared ignoring case, hyphens and underscores (files are named "Reference-Pictures_...").
  HIDDEN_FILENAME_PREFIXES = %w[Reference-Pictures].freeze

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

  # True when the file name, or any folder in its path, starts with a hidden prefix
  def hidden?
    normalize = ->(s) { s.downcase.delete("-_") }
    path.split("/").any? do |part|
      HIDDEN_FILENAME_PREFIXES.any? { |prefix| normalize.(part).start_with?(normalize.(prefix)) }
    end
  end

  def url
    "#{DailyPicker::R2_BASE_URL}/#{path}"
  end
end
