# frozen_string_literal: true

require_dependency 'scribo/application_admin_controller'

module Scribo
  module Admin
    class SitesController < ApplicationAdminController
      before_action :set_objects, except: [:index]

      add_breadcrumb I18n.t('scribo.breadcrumbs.admin.sites'), :admin_sites_path if defined? add_breadcrumb

      def new
        add_breadcrumb('New site', :new_admin_site_path) if defined? add_breadcrumb
        render :edit
      end

      def create
        flash_and_redirect @site.save, admin_sites_url, 'Site created successfully', 'There were problems creating the site'
      end

      def index
        @sites = Site.owned.order(:name)
      end

      def edit
        @site = Site.find(params[:id])
        add_breadcrumb(@site.name, :edit_admin_site_path) if defined? add_breadcrumb
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
                  Site.owned.find(params[:id])
                else
                  params[:site] ? Site.new(site_params) : Site.new
                end
        @contents = @site.contents.where(kind: %w[text redirect]).order(:path, :identifier) if @site
      end

      def site_params
        params.require(:site).permit(:name, :purpose, :scribable_id).tap do |whitelisted|
          whitelisted[:scribable] = GlobalID::Locator.locate_signed(whitelisted[:scribable_id])
        end
      end
    end
  end
end
