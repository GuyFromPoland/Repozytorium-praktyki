require 'google/apis/youtube_v3'

class YoutubeService
  def initialize(api_key)
    @api_key = api_key
    @client = Google::Apis::YoutubeV3::YouTubeService.new
    @client.key = @api_key
  end
  def latest_videos(channel_id, max_results = 5)
    @client.list_searches('snippet', channel_id: channel_id, max_results: max_results, order: 'date')
  end
end
