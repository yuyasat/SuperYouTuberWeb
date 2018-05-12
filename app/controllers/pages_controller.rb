class PagesController < ApplicationController
  def index
    @featured_movies = Movie.active.joins(:featured_movies).merge(FeaturedMovie.active.display_order).shuffle
    @latest_movies = Movie.active.order(published_at: :desc).limit(8)
    @category_movies = Movie.grouped_by_categories(num: 8)
    @mobile_menu_show = true;
  end

  def privacy_policy
  end

  def contact
  end

  def about
  end

  def term
  end

  def component_library
  end
end
