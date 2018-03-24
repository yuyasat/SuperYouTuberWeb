class Location < ApplicationRecord
  belongs_to :movie

  def longitude
    lonlat.x
  end

  def latitude
    lonlat.y
  end
end
