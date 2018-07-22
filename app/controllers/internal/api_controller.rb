class Internal::ApiController < ApplicationController
  def movie_location
    target_cat = params[:path].gsub('/spots/categories', '').split("/").delete_if(&:blank?).last

    locations = Location.joins(:movie).merge(
      target_cat.present? ? Movie.active.of_category(Category.find(target_cat)) : Movie.active
    ).order('movies.published_at desc').includes(:movie).as_json(
        only: :id, methods: %i(longitude latitude),
        include: { movie: { only: :id, methods: :mqdefault_url } }
      )
    render json: locations
  end
end
