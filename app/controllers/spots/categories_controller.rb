class Spots::CategoriesController < ApplicationController
  def index
    @category_movies = Movie.grouped_by_categories(
      num: 8, target_category: Category.find_by(name: 'ジャンルからさがす')
    )
    @root_category = Category.mappable.secondary
  end

  def show
    if params[:id].present?
      category = Category.find(params[:id])
      return redirect_to category.decorate.path, status: 301 unless category.root?
    end

    @category = Category.find(params[:cat3].presence || params[:cat2].presence || params[:id]).decorate
    return redirect_to @category.music_path, status: 301 if @category.music?

    @movies = @category.related_categories_movies.page(params[:page]).per(30)
  end
end
