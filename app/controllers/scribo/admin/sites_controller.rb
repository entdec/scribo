# frozen_string_literal: true

require_dependency 'scribo/application_admin_controller'

module Scribo
  module Admin
    class SitesController < ApplicationAdminController
      before_action :set_objects, except: [:index]

      def new
        @site.scribable = Scribo.config.scribable_objects.first
        @site.save!
        redirect_to(admin_site_contents_path(@site)) and return
      end

      def create
        flash_and_redirect @site.save, admin_site_contents_path(@site), 'Site created successfully', 'There were problems creating the site'
      end

      def index
        @sites = Site.adminable
      end

      def destroy
        @site.contents.rebuild!
        flash_and_redirect @site.destroy, admin_sites_url, 'Site deleted successfully', 'There were problems deleting the site'
      end

      def import
        @sites = Site.adminable
        params[:files].each do |file|
          Scribo::SiteImportService.new(file.path).call
        end
      end

      def export
        name, data = Scribo::SiteExportService.new(@site).call
        send_data data, type: 'application/zip', filename: name
      end

      private

      def set_objects
        @sites = Site.adminable

        @site = if params[:id]
                  Site.adminable.find(params[:id])
                else
                  params[:site] ? Site.new(site_params) : Site.new
                end

        @scribable_objects = Scribo.config.scribable_objects.map { |so| ["#{so.name} (#{so.class.name.demodulize})", so.to_sgid] }
        @selected = @scribable_objects.find { |so| GlobalID::Locator.locate_signed(so[1]) == @site.scribable }
      end

      def site_params
        params.require(:site).permit(:scribable_id).tap do |whitelisted|
          whitelisted[:scribable] = GlobalID::Locator.locate_signed(whitelisted[:scribable_id])
        end
      end
    end
  end
end
