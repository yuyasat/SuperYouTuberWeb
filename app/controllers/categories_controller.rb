class CategoriesController < ApplicationController
  def index
    @category_movies = Movie.grouped_by_categories(num: 6)
    @root_category = Category.root.not_special
                             .where(id: @category_movies.keys.map(&:id)).sort_by_display_order
  end

  def show
    if params[:id].present?
      category = Category.find(params[:id])
      return redirect_to category.decorate.path, status: 301 unless category.root?
    end

    @category = Category.find(params[:cat3].presence || params[:cat2].presence || params[:id])&.decorate
    raise ActiveRecord::RecordNotFound if @category.blank?
    return redirect_to @category.music_path, status: 301 if @category.music?

    @movies = @category.related_categories_movies.page(params[:page]).per(30)
  end
end
