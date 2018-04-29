class Admin::ApiController < ApplicationController
  def movie_info
    return render json: { error: 'Invalid Movie Key' } unless params[:movie_key].length == 11

    render json: JSON.parse(YoutubeApi.get_movie_info(params))
  end

  def movie_exists
    render json: { exists: Movie.exists?(key: params[:movie_key]) }
  end

  def video_artist
    video_artist = VideoArtist.find(video_artist_params[:id])
    form = Admin::SnsAccountForm.new(params)
    form.assign_attributes
    form.save!
    render json: { twitter: video_artist.twitter, instagram: video_artist.instagram }
  end

  def movies
    movies_json = searched_movies.as_json(
                    methods: %i(default_url channel_url),
                    include: {
                      categories: { only: %i(name) },
                      locations: { methods: %i(latitude longitude latlong) },
                    }
                  )

    render json: { movies: movies_json, total_pages: searched_movies.total_pages }
  end

  private

  def searched_movies
    order_cond = params[:sort_by].present? ? { params[:sort_by] => params[:sort_sc] } : { id: :desc }
    movies = Movie.order(order_cond)
    movies = movies.where(key: params[:title_search]) if params[:title_search].present?
    movies.includes(:categories, :locations).page(params[:page]).per(100)
  end

  def video_artist_params
    params.require(:video_artist).permit(:id, :channel, :title)
  end
end
