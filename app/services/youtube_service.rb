require 'google/apis/youtube_v3'

class YoutubeService
  def initialize(api_key)
    @client = Google::Apis::YoutubeV3::YouTubeService.new
    @client.key = api_key
  end

  def resolve_channel_id_from_url(url)
    identifier = extract_identifier(url)
    return identifier if identifier&.start_with?("UC")

    clean_id = identifier&.delete_prefix("@")

    begin
      search = @client.list_searches(
        'snippet',
        q: clean_id,
        type: 'channel',
        max_results: 1
      )
      if search&.items&.any?
        return search.items.first.snippet.channel_id
      end
    rescue Google::Apis::ClientError => e
      Rails.logger.warn "Search failed: #{e.message}"
    end

    nil
  end


  def latest_videos(channel_id, max_results = 5)
    @client.list_searches(
      'snippet',
      channel_id: channel_id,
      type: 'video',
      max_results: max_results,
      order: 'date'
    )
  end

  private

  def extract_identifier(url)
    regex = %r{
      (?:youtube\.com\/channel\/([a-zA-Z0-9_-]+)) |
      (?:youtube\.com\/@([a-zA-Z0-9_-]+)) |
      (?:youtube\.com\/user\/([a-zA-Z0-9_-]+))
    }x

    match = url.match(regex)
    match ? match.captures.compact.first : nil
  end
end
