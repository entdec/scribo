# frozen_string_literal: true

# Adds SEO tags
#
# == Basic usage:
#    {%seo%}
#
class SeoTag < LiquorTag
  def render(context)
    super

    content = context.registers['content']
    site = content.site
    request = context.registers['controller'].request

    %[
<!-- Begin Scribo SEO tag #{Scribo::VERSION} -->
<title>#{site.properties['title']}</title>
<meta name="generator" content="Scribo #{Scribo::VERSION}" />
<meta property="og:title" content="#{content.site.title}" />
<meta name="author" content="#{site.properties['author'].is_a?(String) ? site.properties['author'] : ''}" />
<meta property="og:locale" content="en_US" />
<meta name="description" content="#{site.properties['description']}" />
<meta property="og:description" content="#{site.properties['description']}" />
<link rel="canonical" href="#{request.protocol + request.host}" />
<meta property="og:url" content="#{request.protocol + request.host}" />
<meta property="og:site_name" content="#{content.site.title}" />
<script type="application/ld+json">
{"url":"#{request.protocol + request.host}","headline":"#{site.properties['title']}","name":"#{site.properties['title']}","author":{"@type":"Person","name":"#{site.properties['author']}"},"description":"#{site.properties['description']}","@type":"WebSite","@context":"https://schema.org"}</script>
<!-- End Scribo SEO tag -->
    ]
  end
end

Liquid::Template.register_tag('seo', SeoTag)
