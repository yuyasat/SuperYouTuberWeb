class Location < ApplicationRecord
  belongs_to :movie

  scope :within, ->(south_west_lat, south_west_lng, north_east_lat, north_east_lng) {
    where(%|
      lonlat::geometry && Box2D(
        ST_GeomFromText(
          'LINESTRING(#{south_west_lng} #{south_west_lat}, #{north_east_lng} #{north_east_lat})',
          4326
        )
      )
    |)
  }

  def longitude
    lonlat.x
  end

  def latitude
    lonlat.y
  end
end
