# frozen_string_literal: true

# Add assets (by name) from the current scribo site
#
# == Basic usage:
#    {%asset 'test.png'%}
#
# == Advanced usage:
#    {%asset 'test.png' height="72px"%}
#    {%asset 'test.png' style="height: 72px;"%}
#
# Note: It will only look at published assets
class AssetTag < ScriboTag
  def render(context)
    current_content = context.registers['content']

    content = current_content.site.contents.published.named(@name).first
    case content.content_type_group
    when 'image'
      path = content.path ? content.path : context.registers['controller'].helpers.content_url(content)
      %[<img #{attr_str(context, :src, path)}#{attr_str(context, :alt, content.title, content.name)}#{attr_str(context, :title, content.caption, content.name)}#{attr_str(context, :width, @args[:width])}#{attr_str(context, :height, @args[:height])}#{attr_str(context, :style, @args[:style])}/>]
    end
  end
end

Liquid::Template.register_tag('asset', AssetTag)
