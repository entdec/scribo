# frozen_string_literal: true

require_dependency 'scribo/application_drop'

module Scribo
  # https://jekyllrb.com/docs/variables/#page-variables
  class ContentDrop < ApplicationDrop
    delegate :url, :path, :excerpt, :categories, :tags, :dir, to: :@object
    delegate :site, to: :@object

    def initialize(object)
      @object = object
      @properties = object.properties
    end

    def date
      @object.date
    end

    def id
      @object.full_path
    end

    # FIXME: This breaks when the collection_path is set (https://jekyllrb.com/docs/collections/#setup)
    def collection
      base_dir = @object.dir.split('/').first.gsub('_', '')
      base_dir if @object.site.collections.include?(base_dir)
    end

    # Find out how to merge properties with this drop
    def name
      @properties&.[]('name') || @object.path
    end

    def layout
      @object.layout_name
    end

    def next
      @object.right_sibling
    end

    def previous
      @object.left_sibling
    end

    def content
      Scribo::ContentRenderService.new(@object, @context.registers['controller'], {}).call
    end

    def [](property)
      if respond_to?(property)
        send(property)
      elsif @properties.present?
        @properties[property]
      end
    end

    def categories
      Scribo::ArrayDrop.new(@properties['categories'])
    end

    def tags
      Scribo::ArrayDrop.new(@properties['tags'])
    end

    def liquid_method_missing(method)
      return nil unless @properties

      @properties[method.to_s]
    end
  end
end
