# frozen_string_literal: true

require_dependency 'scribo/application_controller'
require_dependency 'scribo/action_dispatch/request_drop'

module Scribo
  class ContentsController < ApplicationController
    protect_from_forgery except: :show

    def show
      Rails.logger.debug "server_name: '#{request.headers['SERVER_NAME']}'"
      current_site = if scribo_current_site
                       scribo_current_site
                     else
                       Site.site_for_hostname(request.headers['SERVER_NAME'])
                     end

      @content = current_site&.contents&.located(request.path)&.first
      @content ||= current_site&.contents&.located('/404')&.first

      if @content
        if @content.kind == 'redirect'
          redirect_options = Content.redirect_options(@content.render(request: ActionDispatch::RequestDrop.new(request)))
          redirect_to redirect_options.last, status: redirect_options.first
        elsif stale?(last_modified: @content.updated_at, public: true)
          render body: @content.render(request: ActionDispatch::RequestDrop.new(request)), content_type: @content.content_type, layout: false
        end
      else
        render body: '404 Not Found', status: 404
      end
    end
  end
end
