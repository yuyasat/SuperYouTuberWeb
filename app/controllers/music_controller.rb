class MusicController < ApplicationController
  def index
    @category = Category.find_by(id: SpecialCategory.where(url: 'music').select('category_id'))
    @category_movies = Movie.grouped_by_categories(num: 10, target_category: @category)
  end

  def show
    @special_category = SpecialCategory.find_by(url: params[:cat3].presence || params[:cat2].presence)
    @category = @special_category.category

    if @category.children.present?
      @category_movies = Movie.grouped_by_categories(num: 10, target_category: @category)
      return render 'index'
    end

    @video_artist = @category.main_video_artist
  end
end
