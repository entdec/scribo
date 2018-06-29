# frozen_string_literal: true

require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'app', 'drops', 'scribo', 'action_dispatch', 'request_drop.rb'))

module ActionViewHelpers
  def layout_with_scribo(identifier, yield_content)
    current_site = Scribo.config.scribo_site(request.env['SERVER_NAME'], purpose)

    content = current_site.contents.identified(identifier).first
    if content
      Rails.logger.info "Scribo: layout for '#{identifier}' content #{content.id} identifier #{content.identifier}"
      assigns = { 'content' => content, 'request' => ActionDispatch::RequestDrop.new(request) }.merge(assigns).stringify_keys

      controller.instance_variables.reject { |i| i.to_s.starts_with?('@_') }.each do |i|
        assigns[i.to_s[1..-1]] = controller.instance_variable_get(i)
      end

      application_js = content_for?(:js) && content_for(:js)
      registers = { _yield: { '' => yield_content }, controller: controller, application_assets: scribo_application_assets, application_js: application_js, content: content }.merge(registers).stringify_keys
      content.render_with_liquid(content, assigns, registers).html_safe
    else
      yield_content
    end
  end
end
