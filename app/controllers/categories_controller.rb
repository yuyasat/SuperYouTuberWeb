class CategoriesController < ApplicationController
  def index
    @category_movies = Movie.grouped_by_categories(num: 6)
    @root_category = Category.root.not_special
                             .where(id: @category_movies.keys.map(&:id)).sort_by_display_order
  end

  def show
    @category = Category.find(params[:cat3].presence || params[:cat2].presence || params[:id])
    raise ActiveRecord::RecordNotFound if @category.blank?

    @movies = @category.related_categories_movies.page(params[:page]).per(30)
  end
end
