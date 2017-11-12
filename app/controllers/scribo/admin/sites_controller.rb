# frozen_string_literal: true

require_dependency 'scribo/application_controller'

module Scribo
  class Admin::SitesController < ApplicationController
    before_action :authenticate_user!
    before_action :set_objects, except: [:index]
    authorize_resource class: Site

    add_breadcrumb I18n.t('scribo.breadcrumbs.admin.sites'), :admin_sites_path

    def new
      render :edit
    end

    def create
      flash_and_redirect @site.save, admin_sites_url, 'Site created successfully', 'There were problems creating the site'
    end

    def index
      @sites = Site.order(:name)
    end

    def edit
      @site = Site.find(params[:id])
    end

    def update
      flash_and_redirect @site.update(site_params), admin_sites_url, 'Site updated successfully', 'There were problems updating the site'
    end

    def show
      redirect_to :edit_admin_site
    end

    private

    def set_objects
      @site = if params[:id]
                Site.find(params[:id])
              else
                params[:site] ? Site.new(site_params) : Site.new
              end
    end

    def site_params
      params.require(:site).permit(:name)
    end
  end
end
