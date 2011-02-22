class VideosController < ApplicationController
  before_filter :authenticate_user!

  def index
    @videos = current_user.video_feed
  end

  def show
    @video = current_user.video_feed.find(params[:id])
  end

  def new
    @video = Video.new
  end

#  def create
#    @video = Video.new(params[:video])
#    if @video.save
#      @video.convert
#      redirect_to @video, :notice => "Successfully created video."
#    else
#      render :action => 'new'
#    end
#  end

  def create
    @video = current_user.videos.build(params[:video])
    if @video.save
      @video.convert
      redirect_to @video, :notice => "Successfully uploaded video."
    else
      render :action => 'new'
    end
  end

  def edit
    @video = current_user.videos.find(params[:id])
  end

  def update
    @video = current_user.videos.find(params[:id])
    if @video.update_attributes(params[:video])
      redirect_to @video, :notice  => "Successfully updated video."
    else
      render :action => 'edit'
    end
  end

  def destroy
    @video = current_user.videos.find(params[:id])
    @video.destroy
    redirect_to videos_url, :notice => "Successfully destroyed video."
  end
end
