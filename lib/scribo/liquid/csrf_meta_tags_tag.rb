# frozen_string_literal: true

# Asset tag
#
# {% csrf_meta_tags %}
class CsrfMetaTagsTag < Liquid::Tag
  def render(context)
    context.registers['controller'].helpers.csrf_meta_tags
  end
end

Liquid::Template.register_tag('csrf_meta_tags', CsrfMetaTagsTag)
