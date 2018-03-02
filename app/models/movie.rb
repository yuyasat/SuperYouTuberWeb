class Movie < ApplicationRecord
  has_many :movie_tags
  has_many :tags, through: :movie_tags

  SIZES = {
    mqdefault: [320, 180]
  }

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
