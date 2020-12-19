# frozen_string_literal: true

require_dependency 'scribo/application_admin_controller'

module Scribo
  module Api
    class SitesController < ApplicationController
      skip_before_action :verify_authenticity_token
      def import
        sgid = request.authorization&.split&.last
        return unless sgid

        scribable = GlobalID::Locator.locate_signed(request.authorization.split.last, for: 'scribo')

        return unless scribable

        params[:files].each do |file|
          Scribo::SiteImportService.new(file.path, scribable).call
        end
      end
    end
  end
end
