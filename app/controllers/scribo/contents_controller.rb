# frozen_string_literal: true

require_dependency 'scribo/application_controller'
require_dependency 'scribo/action_dispatch/request_drop'

module Scribo
  class ContentsController < ApplicationController
    protect_from_forgery except: :show

    def show
      render scribo: Scribo.config.bucket_for_hostname(request.env['SERVER_NAME']), path: request.path
    end
  end
end
