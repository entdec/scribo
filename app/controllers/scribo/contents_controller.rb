# frozen_string_literal: true

require_dependency 'scribo/application_controller'
require_dependency 'scribo/action_dispatch/request_drop'

module Scribo
  class ContentsController < ApplicationController
    protect_from_forgery except: :show

    def show
      render scribo: request
    rescue StandardError => e
      Scribo.config.logger.error '-' * 80
      Scribo.config.logger.error '=> Content rendering errors: ' + e.message
      Scribo.config.logger.error '=> ' + e.backtrace.map(&:to_s).join("\n")
      Scribo.config.logger.error '-' * 80
      render body: e.message, status: 500
    end
  end
end
