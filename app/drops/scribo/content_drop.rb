# frozen_string_literal: true

require_dependency 'scribo/application_drop'

module Scribo
  class ContentDrop < ApplicationDrop
    delegate :path, to: :@object
    delegate :site, to: :@object

    def [](name)
      method_missing(name)
    end

    def method_missing(method)
      if @properties[method.to_s].is_a? Hash
        Scribo::PropertiesDrop.new(@properties, [method.to_s])
      else
        @properties[method.to_s]
      end
    end
  end
end
