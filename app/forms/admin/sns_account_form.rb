class Admin::SnsAccountForm
  include ActiveModel::Model

  def initialize(params)
    @params = params
    @video_artist = VideoArtist.find(video_artist_params[:id])
  end

  def assign_attributes
    @sns_accounts = sns_accounts_params.reject { |p| p[:account].blank? }.map do |p|
      SnsAccount.find_or_initialize_by(p)
    end
    @video_artist.attributes = video_artist_params
  end

  def save!
    SnsAccount.transaction do
      unnecessary_account_ids = @video_artist.sns_accounts.map(&:id) - @sns_accounts.map(&:id)
      SnsAccount.where(id: unnecessary_account_ids).delete_all
      @sns_accounts.map(&:save!)
      @video_artist.save!
    end
  end

  private

  def video_artist_params
    @params.require(:video_artist).permit(:id, :channel, :title, :kana, :en)
  end

  def sns_accounts_params
    @params[:video_artist][:sns_accounts_attributes].map do |p|
      p.permit(:type, :video_artist_id, :account)
    end
  end
end
