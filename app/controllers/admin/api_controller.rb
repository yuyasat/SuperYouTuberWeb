class Admin::ApiController < ApplicationController
  def movie_info
    return render json: { error: 'Invalid Movie Key' } unless params[:movie_key].length == 11

    url = 'https://www.googleapis.com/youtube/v3/videos'
    parameters = {
      id: params[:movie_key],
      key: ENV['GOOGLE_YOUTUBE_DATA_KEY'],
      part: 'snippet,contentDetails,statistics,status',
    }
    res = Typhoeus.get(url, params: parameters)
    render json: JSON.parse(res.body)
  end

  def movie_exists
    render json: { exists: Movie.exists?(key: params[:movie_key]) }
  end
end
