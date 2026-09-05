manifest = JSON.parse(File.read(Rails.root.join("config", "image_manifest.json")))

manifest.each do |theme, data|
  next unless PoseImage::THEMES.include?(theme)
  (data["poses"] || []).each do |pose|
    path = pose.is_a?(Hash) ? pose["path"] : pose
    tags = pose.is_a?(Hash) ? Array(pose["tags"]).join(",") : ""
    PoseImage.find_or_create_by!(path: path) do |img|
      img.theme = theme
      img.tags  = tags
    end
  end
end

puts "PoseImage count: #{PoseImage.count}"
