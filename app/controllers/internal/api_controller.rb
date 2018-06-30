class Internal::ApiController < ApplicationController
  def movie_location
    render json: scoped_movie.includes(:locations).order(published_at: :desc).distinct.as_json(
      methods: %i(default_url mqdefault_url), include: { locations: { methods: [:longitude, :latitude] }}
    )
  end

  private

  def scoped_movie
    movie = Movie.active.having_location
    movie = movie.of_category(params[:category_id]) if params[:category_id].present?
    movie
  end
end
