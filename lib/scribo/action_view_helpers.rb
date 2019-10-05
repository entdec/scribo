# frozen_string_literal: true

require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'app', 'drops', 'scribo', 'action_dispatch', 'request_drop.rb'))

module ActionViewHelpers
  def layout_with_scribo(identifier, yield_content)
    site = Scribo::SiteFindService.new(hostname: request.env['SERVER_NAME']).call
    content = Scribo::ContentFindService.new(site, identifier: identifier).call
    if content
      Scribo.config.logger.info "Scribo: layout for '#{identifier}' content #{content.id} identifier #{content.identifier}"

      application_js = content_for?(:js) && content_for(:js)
      registers = { _yield: { '' => yield_content }, controller: controller, application_assets: scribo_application_assets, application_js: application_js, content: content }
      # Liquor.render(content.data, assigns: assigns, registers: registers).html_safe
      Scribo::ContentRenderService.new(content, self, registers: registers).call.html_safe
    else
      yield_content
    end
  end
end
