class PagesController < ApplicationController
  def index
    @latest_movies = Movie.new_order.limit(10)
    @category_movies = Movie.grouped_by_categories(num: 5)
  end

  def show; end
end
