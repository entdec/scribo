# frozen_string_literal: true

require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'app', 'drops', 'scribo', 'action_dispatch', 'request_drop.rb'))

module ActionViewHelpers
  def layout_with_scribo(layout_name, yield_content)
    options = { request: request, uri: URI.parse(request.original_url), host: request.host, path: URI.parse(request.original_url).path }
    site = Scribo::SiteFindService.new(options).call

    application_js = content_for?(:js) && content_for(:js)

    content = site.contents.new(kind: 'text', data: yield_content, properties: { layout: layout_name })

    registers = { controller: controller, application_assets: scribo_application_assets, application_js: application_js }
    Scribo::ContentRenderService.new(content, self, registers: registers).call.html_safe
  end
end
