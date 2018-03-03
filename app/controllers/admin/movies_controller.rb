class Admin::MoviesController < ApplicationController
  def index
    @movie = Movie.new
    @movies = Movie.new_order
  end

  def show
  end

  def create
    movie = Movie.new(movie_params)
    message = if movie.save
                { success: "#{movie.key}を追加しました" }
              else
                { error: movie.customized_error_full_messages }
              end
    redirect_to admin_movies_path, flash: message
  end

  private

  def movie_params
    params.require(:movie).permit(
      :url, :key, :status, :title, :description,
      movie_categories_attributes: %i(category_id)
    )
  end
end
