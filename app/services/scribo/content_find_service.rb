# frozen_string_literal: true

require_dependency 'scribo/application_service'

module Scribo
  class ContentFindService < ApplicationService
    attr_reader :options, :site

    def initialize(site, options = {})
      super()
      @site = site
      @options = options
    end

    def perform
      return options[:content] if options[:content].is_a?(Scribo::Content)

      scope = site.contents

      if options[:path]
        path = CGI.unescape(options[:path])
        path = path[site.baseurl.length..-1] if path.start_with?(site.baseurl)

        # Deal with collections
        path_parts = path.split('/')
        first_path_part = path_parts[0]

        if site.collections.include?(first_path_part)
          path_parts[0] = '_' + path_parts[0]
          options[:restricted] = false
          path = path_parts.join('/')
        end
        # End - Deal with collections

        scope = scope.located(path, restricted: options[:restricted])
      end

      # FIXME: Not to pretty
      content = if options[:root]
                  scope.roots.first
                else
                  result = scope.where.not(kind: 'folder').first

                  result = scope.where(kind: 'folder').first unless scope.present?

                  result = Scribo::Content.new(kind: 'text', path: '/directory.link', full_path: '/directory.link', data: "#{options[:path]}/") if result&.folder?

                  result
                end

      # Find by content id
      content ||= Scribo::Content&.published&.find_by_id(options[:path][1..-1]) if options[:path] && options[:path][1..-1].length == 36

      if options[:path] == '/humans.txt'
        content ||= Scribo::Content.new(kind: 'text', path: '/humans.txt', full_path: '/humans.txt', data: Scribo.config.default_humans_txt)
      elsif options[:path] == '/robots.txt'
        content ||= Scribo::Content.new(kind: 'text', path: '/robots.txt', full_path: '/robots.txt', data: Scribo.config.default_robots_txt)
      elsif options[:path] == '/favicon.ico'
        content ||= Scribo::Content.new(kind: 'asset', path: '/favicon.ico', full_path: '/favicon.ico', data: Base64.decode64(Scribo.config.default_favicon_ico))
      end

      # FIXME: Find a better way for this
      content ||= site&.contents&.located('/404')&.first
      content ||= site&.contents&.located('/404.html')&.first
      content ||= site&.contents&.located('/404.md')&.first
      content
    end
  end
end
