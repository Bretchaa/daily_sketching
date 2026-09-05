require "zlib"

class PracticeController < ApplicationController
  THEMES = [
    { key: "figures",      filter_tag: nil,          display_name: "Figure Drawing", example_image_url: "https://assets.dailysketching.app/examples/gesture_warmup/quick_gesture2.jpeg", object_position: "top" },
    { key: "faces",        filter_tag: nil,          display_name: "Portrait & Caricature", example_image_url: "https://assets.dailysketching.app/examples/portrait_quick/example.webp", object_position: "top",
      sub_filters: [ { label: "All", filter_tag: nil }, { label: "Realistic", filter_tag: "portrait" }, { label: "Caricature", filter_tag: "caricature" } ] },
    { key: "hands_feet",   filter_tag: nil,          display_name: "Hands & Feet",   example_image_url: "https://assets.dailysketching.app/examples/hands_feet/example.jpeg",            object_position: "bottom",
      sub_filters: [ { label: "All", filter_tag: nil }, { label: "Hands only", filter_tag: "hand" }, { label: "Feet only", filter_tag: "foot" } ] },
    { key: "basic_shapes", filter_tag: nil,          display_name: "Basic Shapes",   example_image_url: "https://assets.dailysketching.app/examples/still_life/example.jpeg",            object_position: "center" },
    { key: "animals",      filter_tag: nil,          display_name: "Animals",        example_image_url: "https://assets.dailysketching.app/examples/animals/example.jpg",                object_position: "center",
      sub_filters: [ { label: "All", filter_tag: nil }, { label: "Bird", filter_tag: "bird" }, { label: "Dog", filter_tag: "dog" }, { label: "Cat", filter_tag: "cat" }, { label: "Giraffe", filter_tag: "giraffe" }, { label: "Tiger", filter_tag: "tiger" }, { label: "Horse", filter_tag: "horse" }, { label: "Squirrel", filter_tag: "squirel" }, { label: "Lion", filter_tag: "lion" } ] }
  ].freeze

  TIMERS = [
    { label: "30s",      seconds: 30 },
    { label: "1 min",    seconds: 60 },
    { label: "2 min",    seconds: 120 },
    { label: "5 min",    seconds: 300 },
    { label: "No timer", seconds: 0 }
  ].freeze

  def index
    @themes = THEMES
    @timers = TIMERS
  end

  def start
    session[:practice_theme]        = params[:theme]
    session[:practice_filter_tag]   = params[:filter_tag].presence
    session[:practice_filter_tags]  = JSON.parse(params[:filter_tags] || "[]").compact.reject(&:empty?) rescue []
    session[:practice_duration]     = params[:duration].to_i
    session[:practice_poses_count]  = params[:poses_count].to_i.clamp(1, 20)
    session[:practice_seed]         = rand(999_999)
    redirect_to practice_draw_path(step: 1)
  end

  def show
    theme = session[:practice_theme]
    redirect_to practice_path and return unless theme

    @step  = params[:step].to_i
    @total = session[:practice_poses_count].to_i

    if @total > 0 && @step > @total
      redirect_to practice_done_path(count: @total) and return
    end

    multi_tags  = Array(session[:practice_filter_tags]).reject(&:empty?)
    single_tag  = session[:practice_filter_tag]
    filter_tags = multi_tags.any? ? multi_tags : (single_tag ? [single_tag] : nil)

    scope  = PoseImage.where(theme: theme)
    images = if filter_tags
      op = multi_tags.any? ? :all? : :any?
      scope.select { |p| filter_tags.send(op) { |t| p.tags_array.include?(t) } }
    else
      scope.to_a
    end
    paths  = images.map(&:path)

    redirect_to practice_path, alert: "No images found for this category." and return if paths.empty?

    seed = Zlib.crc32("#{session[:practice_seed]}-#{@step}")
    rng  = Random.new(seed)

    @pose_url         = "#{DailyPicker::R2_BASE_URL}/#{paths.sample(random: rng)}"
    @duration_seconds = session[:practice_duration].to_i
    @show_countdown   = @step == 1
  end

  def done
    @pose_count           = params[:count].to_i
    @practice_theme       = session[:practice_theme]
    @practice_filter_tag  = session[:practice_filter_tag]
    @practice_filter_tags = session[:practice_filter_tags]
    @practice_duration    = session[:practice_duration]
    @practice_poses_count = session[:practice_poses_count]
    theme = THEMES.find { |t| t[:key] == @practice_theme }
    @practice_display_name = theme&.dig(:display_name)
  end
end
