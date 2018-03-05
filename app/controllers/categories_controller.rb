class CategoriesController < ApplicationController
  def index
    @category_movies = Movie.grouped_by_categories(num: 10)
    @root_category = Category.root.where(id: @category_movies.keys.map(&:id))
  end

  def show
    @category = Category.find(params[:cat3].presence || params[:cat2].presence || params[:id])
    @movies = @category.belonging_movies
  end
end
