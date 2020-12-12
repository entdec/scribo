# frozen_string_literal: true

require_dependency 'scribo/application_drop'
require 'csv'

module Scribo
  class DataDrop < ApplicationDrop
    attr_accessor :data_path

    def initialize(object, data_path = [])
      @object = object
      @data_path = data_path
    end

    def [](name)
      method_missing(name)
    end

    def method_missing(method)
      content = @object.contents.data((data_path + [method.to_s]).join('/')).first

      return Scribo::DataDrop.new(@object, data_path + [content.path]) if content&.kind == 'folder'

      case content&.content_type
      when 'text/x-yaml'
        Scribo::Utility.yaml_safe_parse(content.data)
      when 'application/json'
        ::JSON.parse(content.data)
      when 'text/csv'
        CSV.parse(content.data, headers: true, liberal_parsing: true, quote_char: '"', col_sep: ';', row_sep: "\r\n").map(&:to_h)
      end
    end
  end
end
