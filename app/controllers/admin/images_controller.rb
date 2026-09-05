class Admin::ImagesController < Admin::BaseController
  PER_PAGE = 50

  def index
    @theme_filter = params[:theme].presence
    @tag_filter   = params[:tag].presence
    @page         = [params[:page].to_i, 1].max

    scope   = @theme_filter ? PoseImage.where(theme: @theme_filter) : PoseImage.all
    all     = scope.order(:theme, :path).to_a
    all     = all.select { |img| img.tags_array.include?(@tag_filter) } if @tag_filter

    @total       = all.size
    @total_pages = [(@total.to_f / PER_PAGE).ceil, 1].max
    @page        = [@page, @total_pages].min
    @images      = all[((@page - 1) * PER_PAGE), PER_PAGE] || []

    @counts   = PoseImage.group(:theme).count
    @all_tags = PoseImage.all.flat_map(&:tags_array).tally.sort_by { |_, c| -c }.map(&:first)
  end

  def new
    @image = PoseImage.new(theme: params[:theme] || "figures")
  end

  def create
    files = Array(params[:image_files]).compact.reject { |f| f.blank? }
    unless files.any?
      flash[:error] = "Please select at least one file."
      @image = PoseImage.new
      redirect_to new_admin_image_path and return
    end

    theme = params.dig(:pose_image, :theme)
    tags  = normalize_tags(params.dig(:pose_image, :tags))

    succeeded = 0
    failures  = []

    files.each do |file|
      filename = file.original_filename.gsub(/\s+/, "_")
      key      = "poses/#{theme}/#{filename}"

      begin
        R2Uploader.upload(file.tempfile, key: key, content_type: file.content_type)
        PoseImage.find_or_create_by!(path: key) do |img|
          img.theme = theme
          img.tags  = tags
        end
        succeeded += 1
      rescue => e
        failures << "#{filename}: #{e.message}"
      end
    end

    flash[:error] = "#{failures.count} failed: #{failures.first(3).join("; ")}" if failures.any?
    redirect_to admin_images_path(theme: theme), notice: "#{succeeded} image#{"s" if succeeded != 1} uploaded."
  end

  def edit
    @image = PoseImage.find(params[:id])
  end

  def update
    @image = PoseImage.find(params[:id])
    @image.theme = params.dig(:pose_image, :theme)
    @image.tags  = normalize_tags(params.dig(:pose_image, :tags))

    if @image.save
      redirect_to admin_images_path(theme: @image.theme), notice: "Updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @image = PoseImage.find(params[:id])
    theme = @image.theme
    @image.destroy
    redirect_to admin_images_path(theme: theme), notice: "Removed from library."
  end

  def bulk_action
    ids    = Array(params[:ids])
    action = params[:action_type]
    images = PoseImage.where(id: ids)

    case action
    when "delete"
      count = images.count
      images.destroy_all
      flash[:notice] = "#{count} image#{"s" if count != 1} deleted."
    when "change_theme"
      images.update_all(theme: params[:new_theme])
      flash[:notice] = "#{images.count} image#{"s" if images.count != 1} moved to #{params[:new_theme].tr("_", " ")}."
    when "add_tag"
      tag = params[:tag].to_s.strip.downcase
      if tag.present?
        images.each { |img| img.update!(tags: (img.tags_array | [tag]).join(",")) }
        flash[:notice] = "Tag \"#{tag}\" added to #{images.count} image#{"s" if images.count != 1}."
      end
    when "remove_tag"
      tag = params[:tag].to_s.strip.downcase
      if tag.present?
        images.each { |img| img.update!(tags: (img.tags_array - [tag]).join(",")) }
        flash[:notice] = "Tag \"#{tag}\" removed from #{images.count} image#{"s" if images.count != 1}."
      end
    end

    redirect_to admin_images_path(theme: params[:return_theme].presence, tag: params[:return_tag].presence)
  end

  private

  def normalize_tags(raw)
    raw.to_s.split(",").map(&:strip).reject(&:empty?).join(",")
  end
end
