class CategoriesController < ApplicationController
  def index
    @category_movies = Movie.grouped_by_categories_except_adult(num: 8)
    @root_category = Category.root.not_special.except_adult
                             .where(id: @category_movies.keys.map(&:id)).sort_by_display_order
  end

  def show
    if params[:id].present?
      category = Category.find(params[:id])
      return redirect_to category.decorate.path, status: 301 unless category.root?
    end

    @category = Category.find(params[:cat3].presence || params[:cat2].presence || params[:id]).decorate
    return redirect_to @category.music_path, status: 301 if @category.music?
    return redirect_to @category.spots_path, status: 301 if @category.mappable?

    @movies = @category.related_categories_movies.page(params[:page]).per(30)
    redirect_to request.path, status: 301 if @movies.blank?
  end
end
