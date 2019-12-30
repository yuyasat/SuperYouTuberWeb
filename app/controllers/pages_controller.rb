class PagesController < ApplicationController
  def index
    @featured_movies = ApplicationRecord.none
    @latest_movies = ApplicationRecord.none
    @category_movies = []
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
  end

  def component_library
  end
end
