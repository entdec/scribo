# frozen_string_literal: true

require_dependency 'scribo/application_service'

module Scribo
  class SiteFindService < ApplicationService
    attr_reader :options

    def initialize(options = {})
      @options = options
    end

    def perform
      return options[:site] if options[:site].is_a?(Scribo::Site)

      site ||= Scribo.config.current_site(options)
      site ||= site_scope(options).first
      site ||= Scribo.config.site_for_hostname(options[:hostname]) if options[:hostname]
      site
    end

    private

    def site_scope(options = {})
      return Scribo::Site.none if options[:site].blank?

      scope = Scribo::Site.titled(options[:site])
      scope = scope.owned_by(options[:owner]) if options[:owner]
      scope
    end
  end
end
