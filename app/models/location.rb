class Location < ApplicationRecord
  belongs_to :movie

  before_validation :set_lonlat, if: -> { lonlat.blank? }

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
    lonlat&.x || @longitude || @latlong[1]
  end

  def latitude
    lonlat&.y || @latitude || @latlong[0]
  end

  def latlong=(value)
    @latlong = value.split(/,|[[:blank:]]/).reject(&:blank?)
  end

  def longitude=(value)
    @longitude = value
  end

  def latitude=(value)
    @latitude = value
  end

  private

  def set_lonlat
    self.lonlat = "POINT (#{longitude} #{latitude})"
  end
end
