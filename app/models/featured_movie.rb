class FeaturedMovie < ApplicationRecord
  attr_accessor :movie_key

  belongs_to :movie

  before_validation :set_movie

  validates :movie, presence: true

  delegate :url, :default_url, :mqdefault_url, :categories, :channel, :channel_url, :title, :key,
           :published_at, :video_artist, to: :movie

  t = arel_table
  scope :active, ->(now = Time.current) {
    where(t[:start_at].lteq(now)).where(t[:end_at].eq(nil).or(t[:end_at].gt(now)))
  }
  scope :display_order, -> { order(start_at: :desc) }

  private

  def set_movie
    return if movie.present?
    self.movie = Movie.find_by(key: movie_key)
  end
end
