class VideoArtist < ApplicationRecord
  has_many :sns_accounts
  has_many :movies, foreign_key: 'channel', primary_key: 'channel'
end
