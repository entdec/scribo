# frozen_string_literal: true

require_dependency 'scribo/application_drop'

module Scribo
  class DataDrop < ApplicationDrop
    def [](name)
      method_missing(name)
    end

    def method_missing(method)
      content = @object.contents.data(method.to_s).first

      case content&.content_type
      when 'text/x-yaml'
        YAML.safe_load(content.data)
      when 'application/json'
        JSON.parse(content.data)
      when 'text/csv'
        CSV.parse(content.data, headers: true)
      end
    end
  end
end
