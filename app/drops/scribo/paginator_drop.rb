# frozen_string_literal: true

require_dependency 'scribo/application_drop'

module Scribo
  class PaginatorDrop < ApplicationDrop
    def initialize(site, content)
      @site = site
      @object = content
    end

    def posts
      @site.contents.posts.to_a
    end
  end
end
