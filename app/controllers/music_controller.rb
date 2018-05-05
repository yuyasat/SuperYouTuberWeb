class MusicController < ApplicationController
  def index
    @category = Category.find_by(id: SpecialCategory.where(url: 'music').select('category_id'))
    @category_movies = Movie.grouped_by_categories(num: 10, target_category: @category)
  end
end
