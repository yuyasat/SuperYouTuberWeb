class Internal::ApiController < ApplicationController
  def movie_location
    locations = Location.joins(:movie).merge(Movie.active)
      .order('movies.published_at desc').includes(:movie).as_json(
        only: :id, methods: %i(longitude latitude),
        include: { movie: { only: :id, methods: :mqdefault_url } }
      )
    render json: locations
  end
end
