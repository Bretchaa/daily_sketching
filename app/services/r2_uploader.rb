class R2Uploader
  BUCKET   = -> { ENV.fetch("R2_BUCKET") }
  ENDPOINT = -> { "https://#{ENV.fetch("R2_ACCOUNT_ID")}.r2.cloudflarestorage.com" }

  def self.upload(file_io, key:, content_type:)
    require "aws-sdk-s3"
    client = Aws::S3::Client.new(
      access_key_id:     ENV.fetch("R2_ACCESS_KEY_ID"),
      secret_access_key: ENV.fetch("R2_SECRET_ACCESS_KEY"),
      region:            "auto",
      endpoint:          ENDPOINT.call,
      force_path_style:  true
    )
    client.put_object(
      bucket:       BUCKET.call,
      key:          key,
      body:         file_io,
      content_type: content_type
    )
  end

  def self.delete(key)
    require "aws-sdk-s3"
    client = Aws::S3::Client.new(
      access_key_id:     ENV.fetch("R2_ACCESS_KEY_ID"),
      secret_access_key: ENV.fetch("R2_SECRET_ACCESS_KEY"),
      region:            "auto",
      endpoint:          ENDPOINT.call,
      force_path_style:  true
    )
    client.delete_object(bucket: BUCKET.call, key: key)
  end
end
