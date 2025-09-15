class AuthorsController < ApplicationController
  # set_author tylko dla akcji, które naprawdę potrzebują ID
  before_action :set_author, only: %i[ show edit update destroy ]
  skip_before_action :set_author, only: [:fetch_latest] # <--- dodane

  # GET /authors or /authors.json
  def index
    @authors = Author.all
  end

  # GET /authors/1 or /authors/1.json
  def show
  end

  # GET /authors/new
  def new
    @author = Author.new
  end

  # GET /authors/1/edit
  def edit
  end

  # POST /authors or /authors.json
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

  # PATCH/PUT /authors/1 or /authors/1.json
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

  # DELETE /authors/1 or /authors/1.json
  def destroy
    @author.destroy!

    respond_to do |format|
      format.html { redirect_to authors_path, notice: "Author was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  # GET /authors/fetch_latest
  def fetch_latest
    api_key = "AIzaSyAwk871ns4ckPgwFVECg1b999PXA2xrwjc"
    channel_id = "UCXnI7wpHJ-x8bafp1BK3DUQ"

    youtube = YoutubeService.new(api_key)
    response = youtube.latest_videos(channel_id, 5)

    @videos = if response
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

  # Use callbacks to share common setup or constraints between actions.
  def set_author
    @author = Author.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def author_params
    params.require(:author).permit(:name, :link, :img)
  end
end
