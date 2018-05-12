class VideoArtist < ApplicationRecord
  KANA = [
    %w(あ い う え お),
    %w(か き く け こ),
    %w(さ し す せ そ),
    %w(た ち つ て と),
    %w(な に ぬ ね の),
    %w(は ひ ふ へ ほ),
    %w(ま み む め も),
    %w(や ゆ よ),
    %w(ら り る れ ろ),
    %w(わ を ん),
  ]

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
  scope :search_kana, ->(kana) {
    kana_column = KANA.select { |kanas| kanas.include?(kana) }.flatten
    where(kana_column.map { |c| "kana like '#{c}%'" }.join(' or ')).order(:kana)
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

  def latest_movie
    movies.order(published_at: :desc).first
  end

  def videos_url
    "https://www.youtube.com/channel/#{channel}/videos"
  end
end
