class VideoArtistsController < ApplicationController
  def index
    @video_artists =
      if params[:kana].present? || params[:en].present?
        VideoArtist.start_with(kana: params[:kana], en: params[:en]).page(params[:page]).per(30)
      else
        VideoArtist.latest_published.page(params[:page]).per(30)
      end
    @alphabets_having_video_artists = VideoArtist.start_alphabet
  end

  def show
    @video_artist = VideoArtist.find_by!(channel: params[:id]).decorate
    @movies = @video_artist.latest_published_movies.page(params[:page]).per(24)
    raise ActiveRecord::RecordNotFound if @movies.blank?
    @instagram_ogp = OpenGraph.new(@video_artist.instagram.url) if @video_artist.instagram.present?
  end
end
