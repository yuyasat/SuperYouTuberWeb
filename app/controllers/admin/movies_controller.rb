class Admin::MoviesController < ApplicationController

  def index
    @movie = Movie.new
    @movies = Movie.new_order
    set_gon_attributes
  end

  def show
    @movie = Movie.find(params[:id])
    set_gon_attributes
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

  def update
    movie = Movie.find(params[:id])
    movie.assign_attributes(movie_params.except(:movie_categories_attributes))
    ActiveRecord::Base.transaction do
      if movie.category_changed?(movie_category_params.values.flat_map(&:values).map(&:to_i))
        movie.movie_categories.delete_all
        movie.movie_categories = movie_category_params.values.map { |p| MovieCategory.new(p) }
      end
      message = if movie.save
                  { success: "#{movie.key}を更新しました" }
                else
                  { error: movie.customized_error_full_messages }
                end
      redirect_to admin_movie_path(movie), flash: message
    end
  end

  def destroy
    movie = Movie.find(params[:id])
    movie.delete
    redirect_to admin_movies_path, flash: { success: "#{movie.key}を削除しました" }
  rescue => e
    redirect_to admin_movie_path(movie), flash: { error: "#{movie.key}の削除に失敗しました" }
  end

  private

  def movie_params
    params.require(:movie).permit(
      :url, :key, :status, :title, :published_at, :channel, :description,
      movie_categories_attributes: %i(category_id)
    )
  end

  def movie_category_params
    movie_params[:movie_categories_attributes]
  end

  def set_gon_attributes
    gon.movie = @movie
    gon.movie_categories = @movie.categories
  end
end
