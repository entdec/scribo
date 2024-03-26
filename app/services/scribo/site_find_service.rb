# frozen_string_literal: true

require_dependency 'scribo/application_service'

module Scribo
  class SiteFindService < ApplicationService
    attr_reader :options

    def initialize(options = {})
      super()
      @options = options
    end

    def perform
      return options[:site] if options[:site].is_a?(Scribo::Site)

      scribable = Scribo.config.scribable_for_request(options[:request])
      return nil unless scribable

      # scope = scribable.sites
      scope = Scribo::Site.all
      scope = scope.for_host(options[:host])
      scope = scope.for_path(options[:path]) if options[:path]
      scope.first
    end
  end
end
