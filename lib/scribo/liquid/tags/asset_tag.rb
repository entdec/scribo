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

    content = current_content.site.contents.published.named(@argv1).first
    case content.content_type_group
    when 'image'
      path = content.path ? content.path : context.registers['controller'].helpers.content_path(content)
      %[<img #{attribute(context, :src, nil, path)}#{attribute(context, :alt, content.title, content.name)}#{attribute(context, :title, content.caption, content.name)}#{attribute(context, :width, @args[:width])}#{attribute(context, :height, @args[:height])}#{attribute(context, :style, @args[:style])}/>]
    end
  end
end

Liquid::Template.register_tag('asset', AssetTag)
