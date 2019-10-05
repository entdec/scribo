# frozen_string_literal: true

require_dependency 'scribo/application_drop'
require 'pry'
module Scribo
  class SiteDrop < ApplicationDrop
    delegate :name, to: :@object

    def initialize(object)
      @object = object
      @properties = object.properties
    end

    def data
      Scribo::DataDrop.new(@object)
    end

    def posts
      @object.contents.posts.to_a
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
