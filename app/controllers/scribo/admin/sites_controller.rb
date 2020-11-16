# frozen_string_literal: true

require_dependency 'scribo/application_admin_controller'

module Scribo
  module Admin
    class SitesController < ApplicationAdminController
      before_action :set_objects, except: [:index]

      def new
        @site = Scribo::Site.create!(scribable: @scribable)
        redirect_to(admin_site_contents_path(@site))
        nil
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
          Scribo::SiteImportService.new(file.path, @scribable).call
        end
      end

      def export
        name, data = Scribo::SiteExportService.new(@site).call
        send_data data, type: 'application/zip', filename: name
      end

      private

      def set_objects
        @sites = Site.adminable
        @site = Site.adminable.find(params[:id]) if params[:id]
        @scribable = GlobalID::Locator.locate_signed(params[:scribable])
      end
    end
  end
end
