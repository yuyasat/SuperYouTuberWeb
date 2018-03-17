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

  def self.create_video_artists
    channel_ids =
      Movie.where.not(channel: VideoArtist.select('video_artists.channel')).pluck(:channel).uniq
    parameters = {
      id: channel_ids.join(','),
      key: ENV['GOOGLE_YOUTUBE_DATA_KEY'],
      part: 'id,snippet',
    }
    res = Typhoeus.get("#{URL}/channels", params: parameters)
    items = JSON.parse(res.body)['items']
    items.each do |item|
      VideoArtist.find_or_create_by(channel: item['id'], title: item.dig('snippet', 'title'))
    end
  end

  def self.set_insufficient_attributes_to_video_artists!
    VideoArtist.insufficient.pluck(:channel).each_slice(20) do |channel_ids|
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
end
