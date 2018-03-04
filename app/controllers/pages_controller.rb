class PagesController < ApplicationController
  def index
    @latest_movies = Movie.new_order.limit(10)
    @category_movies = Movie.grouped_by_categories
  end

  def show; end
end
