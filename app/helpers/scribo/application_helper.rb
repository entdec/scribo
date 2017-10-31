# frozen_string_literal: true

module Scribo
  module ApplicationHelper
    def method_missing(method, *args, &block)
      if method.to_s.end_with?('_path', '_url') && main_app.respond_to?(method)
        main_app.send(method, *args)
      else
        super
      end
    end
  end
end
