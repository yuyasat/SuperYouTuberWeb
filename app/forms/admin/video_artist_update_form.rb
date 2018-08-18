class Admin::VideoArtistUpdateForm
  attr_accessor :params, :video_artist

  def initialize(params)
    @params = params
    @video_artist = VideoArtist.find(params[:id])
  end

  def assign_attributes
    video_artist.assign_attributes(
      video_artist_params.except(:movie_registration_definitions_attributes)
    )
    @movie_registration_definitions =
      if movie_registration_definitions_params.blank?
        []
      else
        movie_registration_definitions_params.select do |k, v|
          v[:definition].present? && v[:category_id].present?
        end.values.map { |p| MovieRegistrationDefinition.new(p) }
      end
  end

  def save
    VideoArtist.transaction do
      if video_artist.movie_registration_definitions_changed?(@movie_registration_definitions)
        video_artist.movie_registration_definitions.destroy_all
        @movie_registration_definitions.each do |definition|
          video_artist.movie_registration_definitions << definition
        end
      end

      if video_artist.save
        { success: "#{video_artist.channel}を更新しました" }
      else
        { error: video_artist.customized_error_full_messages }
      end
    end
  end

  private

  def video_artist_params
    params.require(:video_artist).permit(
      :channel, :title, :editor_description, :description, :kana, :en,
      :auto_movie_registration_type,
      memos_attributes: %i(content),
      movie_registration_definitions_attributes: %i(definition category_id),
    )
  end

  def movie_registration_definitions_params
    video_artist_params[:movie_registration_definitions_attributes]
  end
end
