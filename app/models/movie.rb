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
  has_many :featured_movies
  has_many :locations

  accepts_nested_attributes_for :movie_categories, allow_destroy: true

  validates :url, :key, presence: true
  validates :url, :key, uniqueness: true

  def self.grouped_by_categories(num: 10)
    Category.grouped_category_ids.map do |cat1, ids|
      movies = Movie.joins(:movie_categories)
                    .merge(MovieCategory.where(category: ids)).order(published_at: :desc).limit(num)
      next if movies.blank?
      [cat1, movies]
    end.compact.to_h
  end

  def category_changed?(new_category_ids)
    (movie_categories.pluck(:category_id) - new_category_ids).present?
  end

  def channel_url
    "https://www.youtube.com/channel/#{channel}"
  end

  def default_url
    "http://i.ytimg.com/vi/#{key}/default.jpg"
  end

  def mqdefault_url
    "http://i.ytimg.com/vi/#{key}/mqdefault.jpg"
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
end
