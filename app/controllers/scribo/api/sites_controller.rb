# frozen_string_literal: true

require_dependency 'scribo/application_controller'
module Scribo
  module Api
    class SitesController < ApplicationController
      skip_before_action :verify_authenticity_token
      def import
        sgid = request.authorization&.split&.last
        head(400) && return unless sgid

        scribable = GlobalID::Locator.locate_signed(sgid, for: 'scribo')

        head(401) && return unless scribable

        params[:files].each do |file|
          Scribo::SiteImportService.new(file.path, scribable).call
        end
      end
    end
  end
end
