require 'rspotify'

class SpotifyService
  def initialize(client_id, client_secret)
    RSpotify.authenticate(client_id, client_secret)
  end

  def resolve_artist_id_from_url(url)
    url = url.split('?').first
    regex = %r{spotify\.com/artist/([a-zA-Z0-9]+)}
    match = url.match(regex)
    match ? match[1] : nil
  end

  def latest_albums(artist_id, limit = 5)
    artist = RSpotify::Artist.find(artist_id)
    return [] unless artist

    artist.albums(limit: limit, album_type: 'single,album').map do |item|
      {
        title: item.name,
        link: item.external_urls['spotify'],
        img: item.images.first&.[]('url'),
        release_date: item.release_date
      }
    end
  end

  def resolve_show_id_from_url(url)
    url = url.split('?').first
    regex = %r{spotify\.com/show/([a-zA-Z0-9]+)}
    match = url.match(regex)
    match ? match[1] : nil
  end

  def latest_episodes(show_id, limit = 5)
    show = RSpotify::Show.find(show_id)
    return [] unless show

    show.episodes(limit: limit).map do |episode|
      {
        title: episode.name,
        link: episode.external_urls['spotify'],
        img: episode.images.first&.[]('url'),
        release_date: episode.release_date
      }
    end
  end
end
