class PagesController < ApplicationController
  def index
    @latest_movies = Movie.order(published_at: :desc).limit(10)
    @category_movies = Movie.grouped_by_categories(num: 5)
  end

  def show; end
end
