class YoutubeApi
  URL = 'https://www.googleapis.com/youtube/v3'.freeze
  RESOURCES = ['videos', 'channels']

  def self.get_movie_info(params)
    parameters = {
      id: params[:movie_key],
      key: ENV['GOOGLE_YOUTUBE_DATA_KEY'],
      part: 'snippet,contentDetails,statistics,status',
    }
    res = Typhoeus.get("#{URL}/videos", params: parameters)
    res.body
  end

  def self.set_insufficient_attributes_with_youtube_api
    Movie.where(published_at: nil).find_each do |movie|
      parameters = {
        id: movie.key,
        key: ENV['GOOGLE_YOUTUBE_DATA_KEY'],
        part: 'snippet',
      }
      res = Typhoeus.get("#{URL}/videos", params: parameters)
      item = JSON.parse(res.body)['items'].first

      movie.published_at = Time.zone.parse(item.dig('snippet', 'publishedAt'))
      movie.channel = item.dig('snippet', 'channelId')
      movie.save!
    end
  end

  def self.create_video_artists(channel_ids: nil)
    channel_ids = channel_ids.presence ||
      Movie.where.not(channel: VideoArtist.select('video_artists.channel')).pluck(:channel).uniq
    channel_ids.each_slice(10) do |sliced_channel_ids|
      begin
        parameters = {
          id: sliced_channel_ids.join(','),
          key: ENV['GOOGLE_YOUTUBE_DATA_KEY'],
          part: 'id,snippet',
        }
        res = Typhoeus.get("#{URL}/channels", params: parameters)
        items = JSON.parse(res.body)['items']
        items.each do |item|
          VideoArtist.find_or_create_by(channel: item['id'], title: item.dig('snippet', 'title'))
        end
      rescue => e
        puts "ERROR!!! #{sliced_channel_ids}\t#{e.inspect}"
      end
    end
  end

  def self.set_insufficient_attributes_to_video_artists!(channel_ids: nil)
    video_artists =
      channel_ids.present? ? VideoArtist.where(channel: channel_ids) : VideoArtist.insufficient
    video_artists.pluck(:channel).each_slice(20) do |channel_ids|
      parameters = {
        id: channel_ids.join(','), key: ENV['GOOGLE_YOUTUBE_DATA_KEY'], part: 'id,snippet',
      }
      res = Typhoeus.get("#{URL}/channels", params: parameters)
      items = JSON.parse(res.body)['items']
      items.each do |item|
        va = VideoArtist.find_by(channel: item['id'])
        va.title = item.dig('snippet', 'title')
        va.custom_url = item.dig('snippet', 'customUrl')
        va.description = item.dig('snippet', 'description')
        va.default_thumbnail_url = item.dig('snippet', 'thumbnails', 'default', 'url')
        va.medium_thumbnail_url = item.dig('snippet', 'thumbnails', 'medium', 'url')
        va.high_thumbnail_url = item.dig('snippet', 'thumbnails', 'high', 'url')
        va.save!
      end
    end
  end

  def self.set_promotion_video_movies!(channel, regex, category, target_year, dry_run = true)
    mv_titles = []
    (1..12).each do |month|
      published_after = Time.zone.local(target_year, month).beginning_of_month
      published_before = Time.zone.local(target_year, month).end_of_month

      parameters = {
        channelId: channel, key: ENV['GOOGLE_YOUTUBE_DATA_KEY'], part: 'id,snippet',
        publishedAfter: published_after.rfc3339, publishedBefore: published_before.rfc3339, maxResults: 50,
      }
      res = Typhoeus.get("#{URL}/search", params: parameters)
      items = Array(JSON.parse(res.body)['items'])
      if items.count == 50
        (1..published_before.day).each do |day|
          published_after = Time.zone.local(target_year, month, day).beginning_of_day
          published_before = Time.zone.local(target_year, month, day).end_of_day

          parameters = {
            channelId: channel, key: ENV['GOOGLE_YOUTUBE_DATA_KEY'], part: 'id,snippet',
            publishedAfter: published_after.rfc3339, publishedBefore: published_before.rfc3339, maxResults: 50,
          }
          res = Typhoeus.get("#{URL}/search", params: parameters)
          items = Array(JSON.parse(res.body)['items'])
          mv_items =  items.select { |it| regex === it.dig('snippet', 'title') }
          puts "　　#{published_after}-#{published_before}: #{items.count}, #{mv_items.count}"

          mv_titles << save_items!(mv_items, category, dry_run)
        end
      else
        mv_items =  items.select { |it| regex === it.dig('snippet', 'title') }
        puts "#{published_after}-#{published_before}: #{items.count}, #{mv_items.count}"
        mv_titles << save_items!(mv_items, category, dry_run)
      end
    end
    mv_titles.flatten
  end

  def self.save_items!(items, category, dry_run, auto = false)
    mv_titles = []
    items.each do |item|
      m = Movie.find_or_initialize_by(key: item.dig('id', 'videoId'))
      next if m.persisted?
      m.title = item.dig('snippet', 'title')
      m.description = item.dig('snippet', 'description')
      m.url = "https://www.youtube.com/watch?v=#{m.key}"
      m.published_at = Time.zone.parse(item.dig('snippet', 'publishedAt'))
      m.channel = item.dig('snippet', 'channelId')
      m.categories << category if m.categories.blank? && category.present?
      m.status = 'invisible' if category.blank?
      m.registered_type = 'auto' if auto

      mv_titles << "#{m.key}, #{m.title}"
      unless dry_run
        puts "!!!!CAUTION!!!!#{m.inspect}: #{m.errors.full_messages}" unless m.save
      end
    end
    mv_titles
  end

  # NOTE: APIが正しく動かない（RSSから取得するものを利用する）
  def self.update_latest_published_at(channel)
    va = channel.is_a?(VideoArtist) ? channel : VideoArtist.find_by(channel: channel)
    parameters = {
      channelId: va.channel, key: ENV['GOOGLE_YOUTUBE_DATA_KEY'], part: 'id,snippet',
      order: 'date', maxResults: va.auto_movie_registration_type_ignore? ? 1 : 3,
    }
    res = Typhoeus.get("#{URL}/search", params: parameters)
    items = JSON.parse(res.body)['items']
    if items.blank?
    #  Bugsnag.notify(response: res.inspect)
    end
    save_items_with_defined_category!(items, va) unless va.auto_movie_registration_type_ignore?

    latest_published_at = items.max { |item|
      Time.zone.parse(item.dig("snippet", "publishedAt"))
    }&.dig('snippet', 'publishedAt')
    if latest_published_at.blank?
      return
    else
      # Bugsnag.notify(video_artist: va.inspect)
    end
    va.latest_published_at = latest_published_at
    va.save!
  end

  def self.save_items_with_defined_category!(items, video_artist)
    items.each do |item|
      mrd = video_artist.movie_registration_definitions.find do |m|
        /#{m.definition}/ =~ item.dig('snippet', 'title')
      end
      next if mrd.blank? && video_artist.auto_movie_registration_type_if_definition_exists?
      save_items!([item], mrd&.category, false, true)
    end
  end

  def self.update_latest_published_at_from_rss(channel)
    va = channel.is_a?(VideoArtist) ? channel : VideoArtist.find_by(channel: channel)
    url = "https://www.youtube.com/feeds/videos.xml?channel_id=#{va.channel}"
    res = Typhoeus.get(url)
    body = Hash.from_xml(res.body)
    items = body.dig('feed', 'entry')
    save_items_with_defined_category_from_rss!(items, va) unless va.auto_movie_registration_type_ignore?

    latest_published_at = items.map { |item| Time.zone.parse(item.dig('published')) }.max
    va.latest_published_at = latest_published_at
    va.save!
  end

  def self.save_items_with_defined_category_from_rss!(items, video_artist)
    items.each do |item|
      mrd = video_artist.movie_registration_definitions.find do |m|
        /#{m.definition}/ =~ item['title']
      end
      next if mrd.blank? && video_artist.auto_movie_registration_type_if_definition_exists?
      save_items_from_rss!([item], mrd&.category, false, true)
    end
  end

  def self.save_items_from_rss!(items, category, dry_run, auto = false)
    mv_titles = []
    items.each do |item|
      m = Movie.find_or_initialize_by(key: item['id'].split(':').last)
      next if m.persisted?
      m.title = item['title']
      m.description = item.dig('group', 'description')
      m.url = "https://www.youtube.com/watch?v=#{m.key}"
      m.published_at = Time.zone.parse(item['published'])
      m.channel = item['channelId']
      m.categories << category if m.categories.blank? && category.present?
      m.status = 'invisible' if category.blank?
      m.registered_type = 'auto' if auto

      mv_titles << "#{m.key}, #{m.title}"
      unless dry_run
        puts "!!!!CAUTION!!!!#{m.inspect}: #{m.errors.full_messages}" unless m.save
      end
    end
    mv_titles
  end
end
