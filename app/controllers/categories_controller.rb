class CategoriesController < ApplicationController
  def index
    @root_category = Category.root.all
    @category_movies = Movie.grouped_by_categories(num: 10)
  end

  def show
    params[:cat1]
    params[:cat2]
    params[:cat3]
  end
end
