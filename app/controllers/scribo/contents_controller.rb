# frozen_string_literal: true

require_dependency 'scribo/application_controller'
require_dependency 'scribo/action_dispatch/request_drop'

module Scribo
  class ContentsController < ApplicationController
    protect_from_forgery except: :show

    def show
      current_site = if scribo_current_site
                       scribo_current_site
                     else
                       Site.site_for_hostname(request.headers['SERVER_NAME'])
                     end

      @content = current_site&.contents&.located(request.path)&.first
      @content ||= current_site&.contents&.located('/404')&.first

      if @content

        assigns = { 'request' => ActionDispatch::RequestDrop.new(request) }

        instance_variables.reject { |i| i.to_s.starts_with?('@_') }.each do |i|
          assigns[i.to_s[1..-1]] = instance_variable_get(i)
        end

        registers = { 'controller' => self }.stringify_keys

        if @content.kind == 'redirect'
          redirect_options = Content.redirect_options(@content.render(assigns, registers))
          redirect_to redirect_options.last, status: redirect_options.first
        elsif stale?(last_modified: @content.updated_at, public: true)
          render body: @content.render(assigns, registers), content_type: @content.content_type, layout: false
        end
      else
        render body: '404 Not Found', status: 404
      end
    end
  end
end
