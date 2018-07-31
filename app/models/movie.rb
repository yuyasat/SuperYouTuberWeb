require 'elasticsearch/model'

class Movie < ApplicationRecord
  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks

  # Elasticsearch Settings
  index_name "#{Rails.env}-yt_summary-#{self.name.downcase}"
  settings index: Settings.elasticsearch.index.to_hash do
    mappings dynamic: 'false' do
      indexes :id, type: :long
      indexes :key, type: :keyword, index: true
      indexes :title, type: :text, index: true, analyzer: :ja_text_analyzer
      indexes :status, type: :keyword, index: true
      indexes :published_at, type: :date, format: 'date_time_no_millis'

      indexes :categories do
        indexes :name, type: :keyword, index: :true
        indexes :full_name, type: :text, index: true, analyzer: :ja_text_analyzer
      end

      indexes :video_artist do
        indexes :channel, type: :keyword, index: true
        indexes :title, type: :text, index: true, analyzer: :ja_text_analyzer
        indexes :editor_description, type: :text, index: true, analyzer: :ja_text_analyzer
        indexes :description, type: :text, index: true, analyzer: :ja_text_analyzer
        indexes :kana, type: :keyword, index: :true
      end
    end
  end

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

  enum status: {
    active: 1,
    deleted: 2, # YouTuberが削除した
    invisible: 3, # 非表示
  }

  after_create :create_video_artist, unless: :video_artist

  validates :url, :key, :channel, :published_at, presence: true
  validates :url, :key, uniqueness: true

  scope :latest_published, -> { order(published_at: :desc) }
  scope :of_category, ->(category, only_self: false) {
    category = category.is_a?(Category) ? category : Category.find(category)
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
  scope :having_location, -> { where(id: Location.distinct.select(:movie_id)) }
  scope :non_deleted, -> { where(status: Movie.statuses.except(:deleted).values) }
  scope :mappable, -> {
    where(id: MovieCategory.where(category: Category.mappable).select('movie_categories.movie_id'))
  }

  def self.grouped_by_categories(num: 10, target_category: Category)
    {
      target_category => target_category.try(:movies).presence
    }.merge(
      target_category.grouped_category_ids.map do |cat1, ids|
        movies = Movie.joins(:movie_categories)
                      .active.distinct.merge(MovieCategory.where(category: ids))
                      .order(published_at: :desc).limit(num)
        next if movies.blank?
        [cat1, movies]
      end.compact.to_h
    ).compact
  end

  def self.channels_order_by_latest_published
    Rails.cache.fetch("#{self.name}.#{__method__}", expires_in: 3.hours) do
      Movie.all.order(published_at: :desc)
           .select(%|distinct channel, movies.published_at|).map(&:channel)
    end
  end

  def category_changed?(new_categories)
    movie_categories.pluck(:category_id).sort != new_categories.map(&:category_id).sort
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

  def as_indexed_json(options={})
    as_json(
      only: %i(id key title status),
      methods: %i(published_at_without_milliseconds),
      include: {
        categories: { only: %i(name full_name) },
        video_artist: { only: %i(channel title editor_description description kana) },
      }
    )
  end

  private

  def published_at_without_milliseconds
    published_at.strftime("%Y-%m-%d %H:%M:%S %z")
  end

  def create_video_artist
    ActiveRecord::Base.transaction do
      YoutubeApi.create_video_artists(channel_ids: [channel])
      YoutubeApi.set_insufficient_attributes_to_video_artists!(channel_ids: [channel])
    end
  end
end
