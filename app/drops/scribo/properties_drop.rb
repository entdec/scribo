# frozen_string_literal: true

require_dependency 'scribo/application_drop'

module Scribo
  class PropertiesDrop < ApplicationDrop
    attr_accessor :data_path

    def initialize(object, data_path = [])
      @object = object
      @data_path = data_path
    end

    def liquid_method_missing(method)
      @object.value_at_keypath((data_path + [method.to_s]).join('.'))
    end
  end
end
