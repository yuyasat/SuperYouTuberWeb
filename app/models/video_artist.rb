class VideoArtist < ApplicationRecord
  has_many :sns_accounts
  has_many :twitter_accounts
  has_many :instagram_accounts
  has_many :movies, -> { order(published_at: :desc) }, foreign_key: 'channel', primary_key: 'channel'

  accepts_nested_attributes_for :sns_accounts, allow_destroy: true
  delegate :timeline_url, to: :twitter_accounts

  scope :insufficient, -> {
    columns = column_names.reject { |c| c.in?(%w(id created_at updated_at)) }
    where(columns.map { |c| "#{c} IS NULL" }.join(" OR "))
  }

  def channel_url
    "https://www.youtube.com/channel/#{channel}"
  end

  def twitter
    twitter_accounts.first&.account != 'ない' ? twitter_accounts.first : nil
  end

  def instagram
    instagram_accounts.first&.account != 'ない' ? instagram_accounts.first : nil
  end
end
