class SearchController < ApplicationController
  def index
    raise ActiveRecord::RecordNotFound if params[:keyword].blank?

    @keyword = params[:keyword]
    @movies = Search::Movie.new(search_words: params[:keyword]).execute(page: params[:page])
  end
end
