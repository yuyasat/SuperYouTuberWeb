class PagesController < ApplicationController
  def index
    @latest_movies = Movie.all
  end

  def show; end
end
