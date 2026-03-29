require "json"
require "aws-sdk-s3"

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

account_id = ENV.fetch("R2_ACCOUNT_ID")
bucket     = ENV.fetch("R2_BUCKET")

s3 = Aws::S3::Client.new(
  region: "auto",
  endpoint: "https://#{account_id}.r2.cloudflarestorage.com",
  access_key_id: ENV.fetch("R2_ACCESS_KEY_ID"),
  secret_access_key: ENV.fetch("R2_SECRET_ACCESS_KEY")
)

def list_objects(s3, bucket, prefix)
  keys = []
  s3.list_objects_v2(bucket: bucket, prefix: prefix).each do |page|
    page.contents.each { |obj| keys << obj.key }
  end
  keys
end

manifest = {}

THEMES.each do |theme|
  poses    = list_objects(s3, bucket, "poses/#{theme}/").sort
  examples = list_objects(s3, bucket, "examples/#{theme}/").sort

  manifest[theme] = {
    "poses"    => poses,
    "examples" => examples
  }
end

File.write(
  File.join(__dir__, "../config/image_manifest.json"),
  JSON.pretty_generate(manifest)
)

puts "✅ image_manifest.json generated from R2"
THEMES.each do |t|
  count = manifest.dig(t, "poses")&.size || 0
  status = count > 0 ? "#{count} poses" : "⚠️  empty — upload images to R2 under poses/#{t}/"
  puts "  #{t}: #{status}"
end
