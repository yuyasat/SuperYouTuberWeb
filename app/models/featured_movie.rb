class FeaturedMovie < ApplicationRecord
  attr_accessor :movie_key

  belongs_to :movie

  before_validation :set_movie

  validates :movie, presence: true

  delegate :url, :default_url, :categories, :channel, :channel_url, :title, :key, :published_at,
           to: :movie

  t = arel_table
  scope :active, ->(now = Time.current) {
    where(t[:start_at].lteq(now)).where(t[:end_at].eq(nil).or(t[:end_at].gt(now)))
  }

  private

  def set_movie
    self.movie = Movie.find_by(key: movie_key)
  end
end
