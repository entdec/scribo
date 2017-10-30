# frozen_string_literal: true

require_dependency File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'app', 'drops', 'scribo', 'action_dispatch', 'request_drop.rb'))

module ActionViewHelpers
  def layout_with_scribo(identifier, yield_content, additional_context = {})
    content = current_site.contents.identified(identifier).first if current_site
    if content
      context = { '_yield' => { '' => yield_content }, 'content' => content, 'request' => ActionDispatch::RequestDrop.new(request) }.merge(additional_context).stringify_keys
      content.render_with_liquid(content, context).html_safe
    else
      yield_content
    end
  end
end
