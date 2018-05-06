class PagesController < ApplicationController
  def index
    @featured_movie = Movie.joins(:featured_movies).merge(FeaturedMovie.active).sample
    @latest_movies = Movie.order(published_at: :desc).limit(10)
    @category_movies = Movie.grouped_by_categories(num: 8)
    @mobile_menu_show = true;
  end

  def privacy_policy
  end

  def contact
  end

  def about
  end

  def component_library
  end
end
