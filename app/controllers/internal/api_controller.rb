class Internal::ApiController < ApplicationController
  def movie_location
    render json: Movie.joins(:locations).as_json(include: { locations: { methods: [:longitude, :latitude] }})
  end
end
