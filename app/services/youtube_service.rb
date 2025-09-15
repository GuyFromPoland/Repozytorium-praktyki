class YoutubeService
  def initialize(api_key)
    @api_key = api_key
    @client = Google::Apis::YoutubeV3::YouTubeService.new
    @client.key = @api_key
  end

  def search_videos(query, max_results = 10)
    @client.list_searches('snippet', q: query, max_results: max_results, type: 'video')
  rescue Google::Apis::ClientError => e
    Rails.logger.error("Błąd API YouTube: #{e.message}")
    nil
  end
end
