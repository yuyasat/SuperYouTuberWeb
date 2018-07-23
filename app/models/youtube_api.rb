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

  def self.save_items!(items, category, dry_run)
    mv_titles = []
    items.each do |item|
      m = Movie.find_or_initialize_by(key: item.dig('id', 'videoId'))
      m.title = item.dig('snippet', 'title')
      m.description = item.dig('snippet', 'description')
      m.url = "https://www.youtube.com/watch?v=#{m.key}"
      m.published_at = Time.zone.parse(item.dig('snippet', 'publishedAt'))
      m.channel = item.dig('snippet', 'channelId')
      m.categories << category if m.categories.blank?

      mv_titles << "#{m.key}, #{m.title}"
      unless dry_run
        puts "!!!!CAUTION!!!!#{m.inspect}: #{m.errors.full_messages}" unless m.save
      end
    end
    mv_titles
  end

  def self.update_latest_published_at(channel)
    parameters = {
      channelId: channel, key: ENV['GOOGLE_YOUTUBE_DATA_KEY'], part: 'id,snippet',
      order: 'date', maxResults: 1,
    }
    res = Typhoeus.get("#{URL}/search", params: parameters)
    item = JSON.parse(res.body)['items']&.first
    return if item.blank?
    va = VideoArtist.find_by(channel: channel)
    va.latest_published_at = item.dig('snippet', 'publishedAt')
    va.save!
  end
end
