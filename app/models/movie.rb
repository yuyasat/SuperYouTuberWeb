class Movie < ApplicationRecord
  SIZES = {
    default: [120, 90],
    mqdefault: [320, 180],
  }.freeze

  has_many :movie_categories, dependent: :destroy
  has_many :movie_tags, dependent: :destroy
  has_many :categories, through: :movie_categories
  has_many :tags, through: :movie_tags

  accepts_nested_attributes_for :movie_categories, allow_destroy: true

  validates :url, :key, presence: true
  validates :url, :key, uniqueness: true

  def default_url
    "http://i.ytimg.com/vi/#{key}/default.jpg"
  end

  def mqdefault_url
    "http://i.ytimg.com/vi/#{key}/mqdefault.jpg"
  end

  def width(size = :mqdefault)
    SIZES[size][0]
  end

  def height(size = :mqdefault)
    SIZES[size][1]
  end
end
