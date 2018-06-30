class Internal::ApiController < ApplicationController
  def movie_location
    render json: Movie.non_deleted.having_location.includes(:locations).distinct.as_json(
      methods: %i(default_url mqdefault_url), include: { locations: { methods: [:longitude, :latitude] }}
    )
  end
end
