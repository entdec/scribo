# frozen_string_literal: true

require_dependency 'scribo/application_drop'
require 'pry'
module Scribo
  # See https://jekyllrb.com/docs/variables/#site-variables
  class SiteDrop < ApplicationDrop
    delegate :collections, to: :@object

    def initialize(object)
      @object = object
      @properties = object.properties
    end

    def time
      Time.current
    end

    def pages
      @object.contents.pages.to_a
    end

    def posts
      @object.contents.posts.sort_by { |p| - p.date.to_i }.to_a
    end

    # TODO
    def related_posts
      []
    end

    def static_files
      @object.contents.assets.to_a
    end

    def html_pages
      @object.contents.html_pages.to_a
    end

    def html_files
      @object.contents.html_files.to_a
    end

    def data
      Scribo::DataDrop.new(@object)
    end

    # TODO
    def documents
      []
    end

    # TODO
    def categories
      []
    end

    # TODO
    def tags
      []
    end

    def url
      @properties['url']
    end

    def current_locale
      I18n.locale.to_s
    end

    def locale
      @properties['locale']
    end

    def liquid_method_missing(method)
      if collections.include?(method)
        @object.contents.in_folder("_#{method}").to_a
      else
        @properties[method.to_s]
      end
    end
  end
end
