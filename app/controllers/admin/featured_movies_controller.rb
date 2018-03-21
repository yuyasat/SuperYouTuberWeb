class Admin::FeaturedMoviesController < ApplicationController
  def index
    @featured_movie = FeaturedMovie.new
    @featured_movies = FeaturedMovie.all.page(params[:page]).per(100)
  end

  def create
    featured_movie = FeaturedMovie.new(featured_movie_params)
    message = if featured_movie.save
                { success: "#{featured_movie.movie.key}をおすすめ動画に追加しました" }
              else
                { error: featured_movie.customized_error_full_messages }
              end

    redirect_to admin_featured_movies_path, flash: message
  end

  def featured_movie_params
    params.require(:featured_movie).permit(
      %i(
        movie_key
        start_at(1i) start_at(2i) start_at(3i) start_at(4i) start_at(5i)
        end_at(1i) end_at(2i) end_at(3i) end_at(4i) end_at(5i)
      )
    )
  end
end
