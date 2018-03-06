# frozen_string_literal: true

require_dependency 'scribo/application_controller'

module Scribo
  module Admin
    class SitesController < ApplicationController
      before_action :authenticate_user!
      before_action :set_objects, except: [:index]
      authorize_resource class: Site

      add_breadcrumb I18n.t('scribo.breadcrumbs.admin.sites'), :admin_sites_path

      def new
        add_breadcrumb("New site", :new_admin_site_path)
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
        add_breadcrumb(@site.name, :edit_admin_site_path)
      end

      def update
        flash_and_redirect @site.update(site_params), admin_sites_url, 'Site updated successfully', 'There were problems updating the site'
      end

      def show
        redirect_to :edit_admin_site
      end

      def import
        if request.post?
          flash_and_redirect Site.import(params[:site][:zip_file].path), admin_sites_url, 'Site imported successfully', 'There were problems importing the site'
        end
      end

      def export
        name, data = @site.export
        send_data data, type: 'application/zip', filename: name
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
        params.require(:site).permit(:name, :host_name)
      end
    end
  end
end
