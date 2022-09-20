# frozen_string_literal: true

require_dependency 'scribo/application_drop'

module Scribo
  # https://jekyllrb.com/docs/pagination/#liquid-attributes-available
  class PaginatorDrop < ApplicationDrop
    def initialize(site, content)
      @site = site
      @object = content
      @per_page = site&.properties&.[]('paginate') ? site.properties['paginate'].to_i : 5
    end

    def posts
      @site.contents.posts.order(created_at: :desc).page(page).per(@per_page).to_a 
    end

    def page
      page = 1
      current_path = @context.registers['controller'].request.original_fullpath
      page = current_path.match(%r[/(\d+)/$])[1].to_i if Scribo::Content.paginated?(current_path)
      page
    end

    attr_reader :per_page

    def total_posts
      @site.contents.posts.page(page).per(@per_page).total_count
    end

    def total_pages
      @site.contents.posts.page(page).per(@per_page).total_pages
    end

    def previous_page
      page > 1 ? page - 1 : nil
    end

    def previous_page_path
      current_path = @context.registers['controller'].request.original_fullpath
      previous_path = nil
      if previous_page
        if Scribo::Content.paginated?(current_path)
          previous_path = current_path.gsub(%r[/(\d+)/$], "/#{previous_page}/")
        else
          previous_path = current_path
          previous_path += '/' unless previous_path.ends_with?('/')
          previous_path += "#{next_page}/"
        end
      end
      previous_path
    end

    def next_page
      page < total_pages ? page + 1 : nil
    end

    def next_page_path
      current_path = @context.registers['controller'].request.original_fullpath
      next_path = nil
      if next_page
        if Scribo::Content.paginated?(current_path)
          next_path = current_path.gsub(%r[/(\d+)/$], "/#{next_page}/")
        else
          next_path = current_path
          next_path += '/' unless next_path.ends_with?('/')
          next_path += "#{next_page}/"
        end
      end
      next_path
    end
  end
end
