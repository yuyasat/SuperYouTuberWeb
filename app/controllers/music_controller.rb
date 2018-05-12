class MusicController < ApplicationController
  def index
    music_category = Category.find_by(id: SpecialCategory.where(url: 'music').select('category_id'))
    @category_movies = Movie.grouped_by_categories(num: 10, target_category: music_category)
    @music_categories =
      Category.where(id: @category_movies.keys.map(&:id)).sort_by_display_order.decorate
  end

  def show
    @special_category = SpecialCategory.find_by(url: params[:cat3].presence || params[:cat2].presence)
    @music_categories = @special_category.category.children.have_movies
                                         .sort_by_display_order.decorate

    @target_music_category = @special_category.category.decorate

    if @target_music_category.children.present?
      @category_movies = Movie.grouped_by_categories(num: 10, target_category: @target_music_category)
      @template = 'index'
      return
    end

    @template = 'video_artists/show'
    @video_artist = @target_music_category.main_video_artist
    @movies = @video_artist.movies.latest_published.page(params[:page]).per(24)
  end
end
