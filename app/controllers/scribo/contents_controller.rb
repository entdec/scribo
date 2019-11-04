# frozen_string_literal: true

require_dependency 'scribo/application_controller'
require_dependency 'scribo/action_dispatch/request_drop'

module Scribo
  class ContentsController < ApplicationController
    protect_from_forgery except: :show

    def show
      render scribo: Scribo.config.site_for_uri(URI.parse(request.url)), path: request.path
    rescue StandardError => e
      render body: e.message, status: 500
    end
  end
end
