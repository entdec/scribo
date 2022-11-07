# frozen_string_literal: true

# Adds Feed meta
#
# == Basic usage:
#    {%feed_meta%}
#
class FeedMetaTag < LiquidumTag
  def render(context)
    super

    content = context.registers['content']
    site = content.site
    request = context.registers['controller'].request

    %[
      <!-- Begin Scribo Feed Meta tag #{Scribo::VERSION} -->
    ]
  end
end

Liquid::Template.register_tag('feed_meta', FeedMetaTag)
