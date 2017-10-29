module Scribo
  module ContentHelper
    def render_with_liquid(identifier, yield_content, additional_context = {})
      current_site = current_channel.sites.first || current_channel.sites.new
      content = current_site.contents.identified(identifier).first
      if content
        context = { '_yield' => { '' => yield_content }, 'content' => content }.merge(additional_context).stringify_keys
        content.render_with_liquid(content, context).html_safe
      else
        yield_content
      end
    end
  end
end
