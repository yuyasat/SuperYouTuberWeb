class SearchController < ApplicationController
  def index
    @keyword = params[:keyword]
    @movies = Search::Movie.new(search_words: params[:keyword]).execute(page: params[:page])
  end
end
