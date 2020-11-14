# frozen_string_literal: true

require_dependency 'scribo/application_drop'

module Scribo
  # https://jekyllrb.com/docs/pagination/#liquid-attributes-available
  class PaginatorDrop < ApplicationDrop
    def initialize(site, content)
      @site = site
      @object = content
    end

    def posts
      @site.contents.posts.to_a
    end

    def page
      1
    end

    def per_page
      1
    end

    def total_posts
      posts.size
    end

    def total_pages
      1
    end

    def previous_page
      nil
    end

    def previous_page_path
      nil
    end

    def next_page
      nil
    end

    def next_page_path
      nil
    end
  end
end
