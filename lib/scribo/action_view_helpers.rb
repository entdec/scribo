# frozen_string_literal: true

require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'app', 'drops', 'scribo', 'action_dispatch', 'request_drop.rb'))

module ActionViewHelpers
  def layout_with_scribo(layout_name, yield_content)
    options = { request: request, uri: URI.parse(request.original_url), host: request.host, path: URI.parse(request.original_url).path }
    site = Scribo::SiteFindService.new(options).call

    content = site.contents.layout(layout_name).first

    if content
      Scribo.config.logger.info "Scribo: layout for '#{layout_name}' content #{content.id} identifier #{content.identifier}"

      application_js = content_for?(:js) && content_for(:js)
      registers = { controller: controller, application_assets: scribo_application_assets, application_js: application_js, content: content }
      Scribo::ContentRenderService.new(content, self, registers: registers).call.html_safe
    else
      yield_content
    end
  end
end
