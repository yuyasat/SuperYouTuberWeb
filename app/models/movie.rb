class Movie < ApplicationRecord
  paginates_per 50

  YOUTUBE_API_URL = 'https://www.googleapis.com/youtube/v3'.freeze

  SIZES = {
    default: [120, 90],
    mqdefault: [320, 180],
  }.freeze

  belongs_to :video_artist, foreign_key: 'channel', primary_key: 'channel'

  has_many :movie_categories, dependent: :destroy
  has_many :movie_tags, dependent: :destroy
  has_many :categories, through: :movie_categories
  has_many :tags, through: :movie_tags
  has_many :featured_movies, dependent: :destroy
  has_many :locations

  accepts_nested_attributes_for :movie_categories, reject_if: :all_blank, allow_destroy: true
  accepts_nested_attributes_for :locations, reject_if: :all_blank, allow_destroy: true

  after_create :create_video_artist, unless: :video_artist

  validates :url, :key, :channel, :published_at, presence: true
  validates :url, :key, uniqueness: true

  scope :latest_published, -> { order(published_at: :desc) }
  scope :of_category, ->(category, only_self: false) {
    target_categories = only_self ? category : category.all_children_categories
    where(id: MovieCategory.where(category: target_categories).select('movie_categories.movie_id'))
  }
  scope :within, ->(south_west_lat, south_west_lng, north_east_lat, north_east_lng) {
    where(
      id: Location.within(
        south_west_lat, south_west_lng, north_east_lat, north_east_lng
      ).distinct.select(:movie_id)
    )
  }

  def self.grouped_by_categories(num: 10, target_category: Category)
    target_category.grouped_category_ids.map do |cat1, ids|
      movies = Movie.joins(:movie_categories)
                    .distinct.merge(MovieCategory.where(category: ids))
                    .order(published_at: :desc).limit(num)
      next if movies.blank?
      [cat1, movies]
    end.compact.to_h
  end

  def category_changed?(new_categories)
    (movie_categories.pluck(:category_id) - new_categories.map(&:id)).present?
  end

  def locations_changed?(locations_params_values)
    persisted_locations = locations.select(&:persisted?)
    return true unless locations_params_values.size == persisted_locations.size
    locations_params_values.map { |p|
      [p[:latitude], p[:longitude]].map(&:to_f)
    }.sort != persisted_locations.map { |l| [l.latitude, l.longitude] }.sort
  end

  def channel_url
    "https://www.youtube.com/channel/#{channel}"
  end

  def default_url
    "https://i.ytimg.com/vi/#{key}/default.jpg"
  end

  def mqdefault_url
    "https://i.ytimg.com/vi/#{key}/mqdefault.jpg"
  end

  def embed_url(autoplay: false, mute: false)
    params = {}.tap do |hash|
      hash[:autoplay] = 1 if autoplay
      hash[:mute] = 1 if mute
    end.to_param
    "https://www.youtube.com/embed/#{key}?#{params}"
  end

  def width(size = :mqdefault)
    SIZES[size][0]
  end

  def height(size = :mqdefault)
    SIZES[size][1]
  end

  private

  def create_video_artist
    ActiveRecord::Base.transaction do
      YoutubeApi.create_video_artists(channel_ids: [channel])
      YoutubeApi.set_insufficient_attributes_to_video_artists!(channel_ids: [channel])
    end
  end
end
