class Admin::MovieRegistrationDefinitionsController < AdminController
  def index
    @video_artists = VideoArtist.auto_movie_registration_type_all_or_if_definition_exists
                                .eager_load(movie_registration_definitions: :category)
  end
end
