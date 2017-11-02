# frozen_string_literal: true

require_dependency 'scribo/application_controller'
require_dependency 'scribo/action_dispatch/request_drop'

module Scribo
  class ContentsController < ApplicationController
    def show
      @content = current_site&.contents&.located(request.path)&.first
      @content ||= current_site&.contents&.located('/404')&.first

      if @content
        if @content.kind == 'redirect'
          redirect_to @content.redirect_options.last, status: @content.redirect_options.first
        elsif stale?(last_modified: @content.updated_at, public: true)
          render body: @content.render(request: ActionDispatch::RequestDrop.new(request)), content_type: @content.content_type, layout: false
        end
      else
        render body: '404 Not Found', status: 404
      end
    end
  end
end
