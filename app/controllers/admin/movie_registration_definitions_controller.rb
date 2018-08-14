class Admin::MovieRegistrationDefinitionsController < AdminController
  def index
    @video_artists = VideoArtist.having_movie_registration_definitions
                                .eager_load(movie_registration_definitions: :category)
  end
end
