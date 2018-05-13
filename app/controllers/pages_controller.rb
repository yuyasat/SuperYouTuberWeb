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

  def sitemap
    music_category = Category.find_by(id: SpecialCategory.where(url: 'music').select('category_id'))
    category_movies = Movie.grouped_by_categories(num: 1, target_category: music_category)
    @music_categories = Category.where(id: category_movies.keys.map(&:id)).sort_by_display_order.decorate
  end

  def component_library
  end
end
