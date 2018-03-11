class CategoriesController < ApplicationController
  def index
    @category_movies = Movie.grouped_by_categories(num: 10)
    @root_category = Category.root.where(id: @category_movies.keys.map(&:id)).sort_by_display_order
  end

  def show
    @category = Category.find(params[:cat3].presence || params[:cat2].presence || params[:id])
    @movies = @category.related_categories_movies.page(params[:page])
  end
end
