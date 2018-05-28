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
  ALPHABET_GROUP = [
    %w(A B C D E),
    %w(F G H I J),
    %w(K L M N O),
    %w(P Q R S T),
    %w(U V W X Y Z),
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
  scope :latest_published, -> {
    joins(:movies).eager_load(:movies).order('movies.published_at desc')
  }
  scope :ordr_by_movies_count, ->(sort_by = 'desc') {
    joins(:movies).group('video_artists.id').order("count(video_artists.id) #{sort_by}")
  }
  scope :start_with, ->(kana:, en:) {
    if kana.present?
      kana_column = KANA.select { |kanas| kanas.include?(kana) }.flatten
      where(kana_column.map { |c| "kana like '#{c}%'" }.join(' or ')).order(:kana)
    else
      alphabet_group = ALPHABET_GROUP.select { |alp| alp.include?(en.first) }.flatten
      where(alphabet_group.map { |c| "en like '#{c.downcase}%'" }.join(' or ')).order(:en)
    end
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

  def categories
    Category.where(id: MovieCategory.where(movie: movies).select('category_id'))
  end

  def self.start_alphabet
    select("distinct SUBSTR(ltrim(en), 1 , 1) AS char").order("char").map(&:char).compact.map(&:upcase)
  end

  def self.update_latest_published_at
    where('latest_published_at > ?', Time.current - 30.days).or(
      where(latest_published_at: nil)
    ).find_each do |va|
      YoutubeApi.update_latest_published_at(va.channel)
    end
  end
end
