# frozen_string_literal: true

require_dependency 'scribo/application_controller'
require_dependency 'scribo/action_dispatch/request_drop'

module Scribo
  class ContentsController < ApplicationController
    protect_from_forgery except: :show

    def show
      current_bucket = Scribo.config.bucket_for_hostname(request.env['SERVER_NAME'])

      @content = current_bucket&.contents&.located(request.path)&.first
      if !@content && request.path[1..-1].length == 36
        @content = Content&.published&.find(request.path[1..-1])
      end

      if request.path == '/humans.txt'
        @content = Content.new(kind: 'text', content_type: 'text/plain', data: Scribo.config.default_humans_txt)
      elsif request.path == '/robots.txt'
        @content = Content.new(kind: 'text', content_type: 'text/plain', data: Scribo.config.default_robots_txt)
      elsif request.path == '/favicon.ico'
        @content = Content.new(kind: 'asset', content_type: 'image/x-icon', data: Base64.decode64(Scribo.config.default_favicon_ico))
      end
      @content ||= current_bucket&.contents&.located('/404')&.first

      if @content

        assigns = { 'request' => ActionDispatch::RequestDrop.new(request) }

        instance_variables.reject { |i| i.to_s.starts_with?('@_') }.each do |i|
          assigns[i.to_s[1..-1]] = instance_variable_get(i)
        end

        registers = { 'controller' => self }.stringify_keys

        Scribo.config.logger.info "Scribo: rendering #{@content.id} last-updated #{@content.updated_at} cache-key #{@content.cache_key} path #{@content.path} identifier #{@content.identifier}"
        if @content.kind == 'redirect'
          redirect_options = Content.redirect_options(@content.render(assigns, registers))
          redirect_to redirect_options.last, status: redirect_options.first
        elsif stale?(etag: @content.cache_key, public: true)
          if @content.kind == 'asset'
            send_data(@content.render(assigns, registers), type: @content.content_type, disposition: 'inline')
          else
            render body: @content.render(assigns, registers), content_type: @content.content_type, layout: false
          end
        end
      else
        render body: Scribo.config.default_404_txt, status: 404
      end
    end
  end
end
