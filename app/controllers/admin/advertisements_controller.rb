class Admin::AdvertisementsController < AdminController
  def index
    @advertisement = Advertisement.new
    @advertisements = Advertisement.all.order(id: :desc).page(params[:page]).per(100)
  end

  def create
    ad = Advertisement.new(ad_params)
    message = if ad.save
                { success: "アフィリエイトを追加しました" }
              else
                { error: ad.customized_error_full_messages }
              end
    redirect_to admin_advertisements_path, flash: message
  end

  def update
    ad = Advertisement.find(params[:id])
    ad.assign_attributes(ad_params)
    message = if ad.save
                { success: "#{ad.id}を更新しました" }
              else
                { error: ad.customized_error_full_messages }
              end
    redirect_to "#{admin_advertisements_path}#ad-#{ad.id}", flash: message

  end

  private

  def ad_params
    params[:advertisement][:target] = JSON.parse(params[:advertisement][:target])
    params.require(:advertisement).permit(
      :path, :match_type, :device, :location, :content, :start_at, :end_at,
      target: [:id, :type, :url, orders: []]
    )
  end
end
