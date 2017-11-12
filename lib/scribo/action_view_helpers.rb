# frozen_string_literal: true

require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'app', 'drops', 'scribo', 'action_dispatch', 'request_drop.rb'))

module ActionViewHelpers
  def layout_with_scribo(identifier, yield_content, assigns = {}, registers = {})
    content = scribo_current_site.contents.identified(identifier).first if scribo_current_site
    if content
      assigns = { 'content' => content, 'request' => ActionDispatch::RequestDrop.new(request) }.merge(assigns).stringify_keys
      registers = { '_yield' => { '' => yield_content } }.merge(registers).stringify_keys
      content.render_with_liquid(content, assigns, registers).html_safe
    else
      yield_content
    end
  end
  def layout_with_scribo_site(site, identifier, yield_content, assigns = {}, registers = {})
    content = site.contents.identified(identifier).first if scribo_current_site
    if content
      assigns = { 'content' => content, 'request' => ActionDispatch::RequestDrop.new(request) }.merge(assigns).stringify_keys
      registers = { '_yield' => { '' => yield_content } }.merge(registers).stringify_keys
      content.render_with_liquid(content, assigns, registers).html_safe
    else
      yield_content
    end
  end
end
