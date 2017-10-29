# frozen_string_literal: true

module Scribo
  class ApplicationController < ::ApplicationController
    protect_from_forgery with: :exception

    def method_missing(method, *args, &block)
      if method.to_s == 'current_site'
        Rails.logger.warn 'Scribo WARNING: Please define a current_site method in your ApplicationController'
        Site.first || Site.new
      end
    end
  end
end
