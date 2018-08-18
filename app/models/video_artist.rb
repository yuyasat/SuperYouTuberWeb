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
  has_many :movies, foreign_key: 'channel', primary_key: 'channel'
  has_many :movie_categories, through: :movies
  has_many :memos, -> { order(updated_at: :desc) }, as: :target, dependent: :delete_all
  has_many :movie_registration_definitions

  accepts_nested_attributes_for :sns_accounts, reject_if: :all_blank, allow_destroy: true
  accepts_nested_attributes_for :memos, reject_if: :all_blank, allow_destroy: true
  accepts_nested_attributes_for :movie_registration_definitions,
                                reject_if: :all_blank, allow_destroy: true
  delegate :timeline_url, to: :twitter_accounts

  enum auto_movie_registration_type: {
    ignore: 0,
    all: 1,
    if_definition_exists: 2,
  }, _prefix: true

  after_create :set_kana_and_en!, if: -> { kana.blank? || en.blank? }

  scope :insufficient, -> {
    columns = column_names.reject { |c| c.in?(%w(id created_at updated_at)) }
    where(columns.map { |c| "#{c} IS NULL" }.join(" OR "))
  }
  scope :latest_published, ->(sort_by = 'desc') {
    va_at = arel_table
    mv_at = Movie.arel_table

    movies_latest_registered_published_at =
      mv_at.project(Arel.sql('movies.channel as channel, MAX(published_at) as published_at'))
           .group('movies.channel').as('movies_latest_registered_published_at')

    join_conds =
      va_at.join(movies_latest_registered_published_at, Arel::Nodes::InnerJoin)
           .on(movies_latest_registered_published_at[:channel].eq(va_at[:channel])).join_sources

    joins(join_conds).order("movies_latest_registered_published_at.published_at #{sort_by}")
  }
  scope :order_by_movies_count, ->(sort_by = 'desc') {
    joins(:movies).group('video_artists.id').order("count(video_artists.id) #{sort_by}")
  }
  scope :order_by_ununpdated_period, ->(sort_by = 'desc') {
    joins(%|
      INNER JOIN (
        SELECT
          "movies"."channel" AS movies_channel,
          MAX(published_at) AS max_published_at
        FROM
          "movies"
        GROUP BY
          "movies"."channel"
      ) AS movies_max_published_at
      ON video_artists.channel = movies_max_published_at.movies_channel
    |).order("video_artists.latest_published_at - movies_max_published_at.max_published_at #{sort_by}")
  }
  scope :order_by_music, ->(sort_by = 'desc') {
    order(%|
      video_artists.channel = ANY(ARRAY['#{music_video_artists_channels.join("','")}']) #{sort_by}
    |)
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
  scope :having_non_deleted_movies, -> {
    where(channel: Movie.non_deleted.select('movies.channel').distinct)
  }
  scope :auto_movie_registration_type_all_or_if_definition_exists, -> {
    where(auto_movie_registration_type: auto_movie_registration_types.except('ignore').values)
  }

  def channel_url
    "https://www.youtube.com/channel/#{channel}"
  end

  def latest_published_movies
    return movies.order(id: :desc) if channel.in?(%w|
      UCd7IaeJx3BjvQ5MQbJMowvw UCeqlHZDmUEQQHYqnei8doYg
    |)
    movies.latest_published
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
    "https://www.youtube.com/channel/#{channel}/videos#{
      VideoArtist.music_video_artists_channels.include?(channel) ? '?sort=dd&view=64' : ''
    }"
  end

  def categories
    Category.where(id: MovieCategory.where(movie: movies).select('category_id'))
  end

  def music?
    categories.any?(&:music?)
  end

  def most_relevant_category
    movie_categories.group(:category).count.max_by { |_k, v| v }.first
  end

  def most_relevant_movie_registration_definitions
    movie_registration_definitions.order(:created_at).presence ||
      [movie_registration_definitions.new(category: most_relevant_category)]
  end

  def kana_converted_from_title
    Kakasi.kakasi(
      '-w',
      title.gsub(
        /[!"#$%'()\*\+\-\.,\/:;<=>?\[\\\]^_`{|}~]/, '' # except & and @
      ).gsub(
        /[&@]/, '&' => 'あんど', '@' => 'あっと'
      )
    ).split.map do |str|
      case str
      when /\A[a-zA-Z]+\z/     then str.downcase.to_kana                      # アルファベット
      when /\A\d+\z/          then Kakasi.kakasi('-JH', str.to_i.to_j(:all)) # 数字
      when /\A\d+[a-zA-Z]+\z/ then nil                                       # 数字+アルファベット
      else                         Kakasi.kakasi('-JH -KH', str)
      end
    end.compact.join
  rescue => e
    Bugsnag.notify("(Handled) Kana Convert Failed. id: #{id}, title: #{title}")
    title
  end

  def en_converted_from_title
    Kakasi.kakasi('-Ja -Ka -Ha', title).tr(' ', '').downcase
  rescue => e
    Bugsnag.notify("(Handled) En Convert Failed. id: #{id}, title: #{title}")
    title
  end

  def movie_registration_definitions_changed?(new_movie_registration_definitions)
    return movie_registration_definitions.present? if new_movie_registration_definitions.blank?
    movie_registration_definitions.sort_by { |d|
      [d.category_id, d.definition]
    }.map { |mrd|
      mrd.slice(:category_id, :definition, :match_type)
    } != new_movie_registration_definitions.sort_by { |d|
      [d.category_id, d.definition]
    }.map { |mrd|
      mrd.slice(:category_id, :definition, :match_type)
    }
  end

  def self.music_video_artists_channels
    RequestStore.fetch("#{name}.#{__method__}") do
      Category.musicable.no_children.includes(:movies).map { |cat|
        cat.movies.group_by(&:channel).max_by { |_k, v| v.size }.first
      }.uniq
    end
  end

  def self.start_alphabet
    select("distinct SUBSTR(ltrim(en), 1 , 1) AS char").order("char").map(&:char).compact.map(&:upcase)
  end

  def self.update_latest_published_at(channel = nil)
    return YoutubeApi.update_latest_published_at(channel) if channel.present?

    where('latest_published_at > ?', Time.current - 30.days).or(
      where(latest_published_at: nil)
    ).find_each do |va|
      YoutubeApi.update_latest_published_at(va.channel)
    end
  end

  private

  def set_kana_and_en!
    update!(kana: kana_converted_from_title, en: en_converted_from_title)
  end
end
