# frozen_string_literal: true

# Adds CSRF meta tags
#
# == Basic usage:
#    {%csrf_meta_tags%}
#
class CsrfMetaTagsTag < LiquorTag
  def render(context)
    super

    context.registers['controller'].helpers.csrf_meta_tags
  end
end

Liquid::Template.register_tag('csrf_meta_tags', CsrfMetaTagsTag)
