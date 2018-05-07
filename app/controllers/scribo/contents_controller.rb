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
      if request.path == '/humans.txt'
        @content = Content.new(kind: 'text', content_type: 'text/plain', data: Scribo.config.default_humans_txt)
      elsif request.path == '/robots.txt'
        @content = Content.new(kind: 'text', content_type: 'text/plain', data: Scribo.config.default_robots_txt)
      elsif request.path == '/favicon.ico'
        @content = Content.new(kind: 'asset', content_type: 'image/x-icon', data: Base64.decode64(Scribo.config.default_favicon_ico))
      end
      @content ||= current_site&.contents&.located('/404')&.first

      if @content

        assigns = { 'request' => ActionDispatch::RequestDrop.new(request) }

        instance_variables.reject { |i| i.to_s.starts_with?('@_') }.each do |i|
          assigns[i.to_s[1..-1]] = instance_variable_get(i)
        end

        registers = { 'controller' => self }.stringify_keys

        Rails.logger.info "Scribo: rendering #{@content.id} last-updated #{@content.last_updated_at} cache-key #{@content.cache_key} path #{@content.path} identifier #{@content.identifier}"
        if @content.kind == 'redirect'
          redirect_options = Content.redirect_options(@content.render(assigns, registers))
          redirect_to redirect_options.last, status: redirect_options.first
        elsif stale?(@content)
          render body: @content.render(assigns, registers), content_type: @content.content_type, layout: false
        end
      else
        render body: Scribo.config.default_404_txt, status: 404
      end
    end
  end
end
