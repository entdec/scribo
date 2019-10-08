# frozen_string_literal: true

require_dependency 'scribo/application_drop'

module Scribo
  # https://jekyllrb.com/docs/variables/#page-variables
  class ContentDrop < ApplicationDrop
    delegate :path, :excerpt, :categories, :tags, :dir, to: :@object
    delegate :site, to: :@object

    def initialize(object)
      @object = object
      @properties = object.properties
    end

    def url
      @object.full_path
    end

    def date
      @object.date
    end

    # TODO
    def id
    end

    def collection
    end

    def name
      @object.path
    end

    def next
      @object.right_sibling
    end

    def previous
      @object.left_sibling
    end

    def liquid_method_missing(method)
      if @properties[method.to_s].is_a? Hash
        Scribo::PropertiesDrop.new(@properties, [method.to_s])
      else
        @properties[method.to_s]
      end
    end
  end
end
