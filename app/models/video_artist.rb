class VideoArtist < ApplicationRecord
  has_many :sns_accounts
  has_many :twitter_accounts
  has_many :instagram_accounts
  has_many :movies, foreign_key: 'channel', primary_key: 'channel'

  accepts_nested_attributes_for :sns_accounts, allow_destroy: true

  def channel_url
    "https://www.youtube.com/channel/#{channel}"
  end

  def twitter
    twitter_accounts.first&.account
  end

  def instagram
    instagram_accounts.first&.account
  end
end
