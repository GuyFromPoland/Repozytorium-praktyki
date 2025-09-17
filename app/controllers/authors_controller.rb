class AuthorsController < ApplicationController
  before_action :set_author, only: %i[ show edit update destroy fetch_latest ]

  # GET /authors
  def index
    @authors = Author.all
  end

  # GET /authors/1
  def show
  end

  # GET /authors/new
  def new
    @author = Author.new
  end

  # GET /authors/1/edit
  def edit
  end

  # POST /authors
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

  # PATCH/PUT /authors/1
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

  # DELETE /authors/1
  def destroy
    @author.destroy!

    respond_to do |format|
      format.html { redirect_to authors_path, notice: "Author was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  # GET /authors/1/fetch_latest
  def fetch_latest
    youtube = YoutubeService.new("AIzaSyAwk871ns4ckPgwFVECg1b999PXA2xrwjc")
    url = @author.link

    channel_id = youtube.resolve_channel_id_from_url(url)

    if channel_id.nil?
      @videos = []
      flash[:alert] = "Failed to find channel from: #{url}"
      return
    end

    response = youtube.latest_videos(channel_id, 5)

    @videos = if response&.items&.any?
                response.items.map do |item|
                  {
                    title: item.snippet.title,
                    link: "https://www.youtube.com/watch?v=#{item.id.video_id}",
                    img: item.snippet.thumbnails.medium.url
                  }
                end
              else
                []
              end
  end


  private

  def set_author
    @author = Author.find(params[:id])
  end

  def author_params
    params.require(:author).permit(:name, :link, :img)
  end

  def get_channel_id_from_url(url)
    regex = %r{
      (?:youtube\.com\/channel\/([a-zA-Z0-9_-]+)) |   # https://youtube.com/channel/UC...
      (?:youtube\.com\/@([a-zA-Z0-9_-]+))         |   # https://youtube.com/@username
      (?:youtube\.com\/user\/([a-zA-Z0-9_-]+))        # https://youtube.com/user/username
    }x

    match = url.match(regex)
    match ? match.captures.compact.first : nil
  end
end

