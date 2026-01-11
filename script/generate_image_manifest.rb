# script/generate_image_manifest.rb
require "json"

THEMES = %w[gesture portrait long_poses].freeze
IMAGE_EXTENSIONS = %w[jpg jpeg png webp].freeze

def images_for(path)
  IMAGE_EXTENSIONS.flat_map do |ext|
    Dir.glob("#{path}/*.#{ext}")
  end.sort
end

manifest = {}

THEMES.each do |theme|
  poses = images_for("public/poses/#{theme}")
            .map { |p| p.sub("public/", "") }

  examples = images_for("public/examples/#{theme}")
               .map { |p| p.sub("public/", "") }

  manifest[theme] = {
    "poses" => poses,
    "examples" => examples
  }
end

File.write(
  "config/image_manifest.json",
  JSON.pretty_generate(manifest)
)

puts "✅ image_manifest.json generated"

