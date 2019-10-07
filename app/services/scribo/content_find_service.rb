# frozen_string_literal: true

require_dependency 'scribo/application_service'

module Scribo
  class ContentFindService < ApplicationService
    attr_reader :options, :site

    def initialize(site, options = {})
      @site = site
      @options = options
    end

    def perform
      return options[:content] if options[:content].is_a?(Scribo::Content)

      scope = site.contents

      scope = scope.located(options[:path], restricted: options[:restricted]) if options[:path]
      content = if options[:root]
                  # bah
                  scope.roots.first
                else
                  scope.first
                end

      # Find by content id
      content ||= Scribo::Content&.published&.find(options[:path][1..-1]) if options[:path] && options[:path][1..-1].length == 36

      if options[:path] == '/humans.txt'
        content = Scribo::Content.new(kind: 'text', content_type: 'text/plain', data: Scribo.config.default_humans_txt)
      elsif options[:path] == '/robots.txt'
        content = Scribo::Content.new(kind: 'text', content_type: 'text/plain', data: Scribo.config.default_robots_txt)
      elsif options[:path] == '/favicon.ico'
        content = Scribo::Content.new(kind: 'asset', content_type: 'image/x-icon', data: Base64.decode64(Scribo.config.default_favicon_ico))
      end

      # FIXME: Find a better way for this
      content ||= site&.contents&.located('/404')&.first
      content ||= site&.contents&.located('/404.html')&.first
      content ||= site&.contents&.located('/404.md')&.first
      content
    end
  end
end
