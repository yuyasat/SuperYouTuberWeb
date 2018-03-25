class Internal::ApiController < ApplicationController
  def movie_location
    render json: Movie.within(
      *params.values_at(*%i(south_west_lat south_west_lng north_east_lat north_east_lng))
    ).includes(:locations).distinct.as_json(
      methods: %i(default_url mqdefault_url), include: { locations: { methods: [:longitude, :latitude] }}
    )
  end
end
