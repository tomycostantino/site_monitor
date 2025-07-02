class SitesController < ApplicationController
  before_action :set_sites, only: [ :index ]
  before_action :set_site, only: [ :show, :new, :edit, :update, :destroy ]
  def index
    @sites = Site.all
  end

  def show
  end

  def new
  end

  def create
    @site = Site.new(site_params)
    if @site.save
      redirect_to @site, notice: "Site was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @site.update(site_params)
      redirect_to @site, notice: "Site was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @site.destroy
    redirect_to root_path, notice: "Site was successfully deleted."
  end

  private
  def set_sites
    @sites = Site.all.order(:created_at)
  end

  def set_site
    @site = params[:id] ? Site.find(params[:id]) : Site.new
  end

  def site_params
    params.require(:site).permit(:title, :url, :monitor_start_time, :monitor_end_time,
                                 :frequency_seconds, :timezone_offset_hours, :active)
  end
end
