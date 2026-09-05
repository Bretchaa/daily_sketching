namespace :reorganize_r2 do
  desc "Copy gesture/ + long_poses/ → figures/, portrait/ + caricature/ → faces/"
  task run: :environment do
    require "aws-sdk-s3"

    client = Aws::S3::Client.new(
      access_key_id:     ENV.fetch("R2_ACCESS_KEY_ID"),
      secret_access_key: ENV.fetch("R2_SECRET_ACCESS_KEY"),
      region:            "auto",
      endpoint:          "https://#{ENV.fetch("R2_ACCOUNT_ID")}.r2.cloudflarestorage.com",
      force_path_style:  true,
      ssl_verify_peer:   false
    )
    bucket = ENV.fetch("R2_BUCKET")

    def copy_prefix(client, bucket, from_prefix, to_prefix)
      copied = 0
      skipped = 0
      client.list_objects_v2(bucket: bucket, prefix: from_prefix).each do |resp|
        resp.contents.each do |obj|
          filename  = File.basename(obj.key)
          dest_key  = "#{to_prefix}#{filename}"

          begin
            client.head_object(bucket: bucket, key: dest_key)
            puts "  skip (exists): #{dest_key}"
            skipped += 1
          rescue Aws::S3::Errors::NotFound
            client.copy_object(
              bucket:      bucket,
              copy_source: "#{bucket}/#{obj.key}",
              key:         dest_key
            )
            puts "  copied: #{obj.key} → #{dest_key}"
            copied += 1
          end
        end
      end
      puts "  → #{copied} copied, #{skipped} skipped"
    end

    puts "=== gesture/ → figures/ ==="
    copy_prefix(client, bucket, "poses/gesture/", "poses/figures/")

    puts "=== long_poses/ → figures/ ==="
    copy_prefix(client, bucket, "poses/long_poses/", "poses/figures/")

    puts "=== portrait/ → faces/ ==="
    copy_prefix(client, bucket, "poses/portrait/", "poses/faces/")

    puts "=== caricature/ → faces/ ==="
    copy_prefix(client, bucket, "poses/caricature/", "poses/faces/")

    puts "Done."
  end
end
