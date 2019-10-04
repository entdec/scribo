# frozen_string_literal: true

require_dependency 'scribo/application_drop'

module Scribo
  class SiteDrop < ApplicationDrop
    delegate :name, to: :@object

    def initialize(object)
      @object = object
      @properties = object.properties
    end

    def children
      @object.children.to_a
    end

    def data
      Scribo::DataDrop.new(@object)
    end

    private
    def respond_to_missing?(name, _include_private = false)
      @properties.has_key?(name.to_s)
    end

    def method_missing(method, *args, &block)
      @properties[method.to_s]
    end
  end
end
