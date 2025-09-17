class AuthorsController < ApplicationController
  before_action :set_author, only: %i[ show edit update destroy fetch_latest fetch_latest_spotify ]

  def index
    @authors = Author.all
  end

  def show
  end

  def new
    @author = Author.new
  end

  def edit
  end

  def create
    @author = Author.new(author_params)
    respond_to do |format|
      if @author.save
        format.html { redirect_to @author, notice: "Author was successfully created." }
        format.json { render :show, status: :created, location: @author }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @author.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @author.update(author_params)
        format.html { redirect_to @author, notice: "Author was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @author }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @author.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @author.destroy!
    respond_to do |format|
      format.html { redirect_to authors_path, notice: "Author was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end


  def fetch_latest
    youtube = YoutubeService.new("AIzaSyAwk871ns4ckPgwFVECg1b999PXA2xrwjc")
    url = @author.link
    channel_id = youtube.resolve_channel_id_from_url(url)

    if channel_id.nil?
      @videos = []
      flash[:alert] = "Could not find YouTube channel for link: #{url}"
      return
    end

    response = youtube.latest_videos(channel_id, 5)
    @videos = if response&.items&.any?
                response.items.map do |item|
                  {
                    title: item.snippet.title,
                    link: "https://www.youtube.com/watch?v=#{item.id.video_id}",
                    img: item.snippet.thumbnails.medium.url,
                    release_date: item.snippet.published_at
                  }
                end
              else
                []
              end
  end


  def fetch_latest_spotify
    client_id = "ae1560f96c754a0bb73b7d8bc27f3f0f"
    client_secret = "a3214242872e4d43b53c58ce766e4e04"
    spotify = SpotifyService.new(client_id, client_secret)

    url = @author.img

    if url.include?("/artist/")
      id = spotify.resolve_artist_id_from_url(url)
      if id.nil?
        @items = []
        flash[:alert] = "Could not find artist for link: #{url}"
        return
      end
      @items = spotify.latest_albums(id, 5)
    elsif url.include?("/show/")
      id = spotify.resolve_show_id_from_url(url)
      if id.nil?
        @items = []
        flash[:alert] = "Could not find podcast for link: #{url}"
        return
      end
      @items = spotify.latest_episodes(id, 5)
    else
      @items = []
      flash[:alert] = "Invalid Spotify link: #{url}"
    end
  end

  private

  def set_author
    @author = Author.find(params[:id])
  end

  def author_params
    params.require(:author).permit(:name, :link, :img)
  end
end