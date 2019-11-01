# frozen_string_literal: true

require_dependency 'scribo/application_controller'
require_dependency 'scribo/action_dispatch/request_drop'

module Scribo
  class ContentsController < ApplicationController
    protect_from_forgery except: :show

    def show
      render scribo: Scribo.config.site_for_uri(URI.parse(request.url)), path: request.path
    # rescue StandardError => _e
    #   render body: Scribo.config.default_404_txt, status: 404
    end
  end
end
