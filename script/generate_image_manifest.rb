require "json"

THEMES = %w[
  gesture
  long_poses
  portrait
  line_of_action
  negative_space
  silhouette
  proportion
  hands_feet
  animal_gesture
  architecture
].freeze

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
THEMES.each do |t|
  count = manifest.dig(t, "poses")&.size || 0
  status = count > 0 ? "#{count} poses" : "⚠️  empty — add images to public/poses/#{t}/"
  puts "  #{t}: #{status}"
end
