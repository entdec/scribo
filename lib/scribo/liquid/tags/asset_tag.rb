# frozen_string_literal: true

# Add assets (by name) from the current Liquor site
#
# == Basic usage:
#    {%asset 'test.png'%}
#
# == Advanced usage:
#    {%asset 'test.png' height="72px"%}
#    {%asset 'test.png' style="height: 72px;"%}
#
# Note: It will only look at published assets
class AssetTag < LiquorTag
  include Rails.application.routes.url_helpers

  def render(context)
    super

    current_content = context.registers['content']

    content = current_content.site.contents.published.located(argv1, restricted: false).first

    return "<!-- asset '#{argv1}' not found -->" unless content

    full_path = content.full_path
    full_path = context.registers['controller'].helpers.scribo.content_path(content) if File.basename(full_path).include?('/_')

    case content&.media_type
    when 'image'
      %[<img] +
        attr_str(:src, arg(:src), full_path) +
        attr_str(:alt, content.properties['title'], content.properties['title']) +
        attr_str(:title, content.properties['caption'], content.properties['caption']) +
        attr_str(:width, arg(:width)) +
        attr_str(:height, arg(:height)) +
        attr_str(:style, arg(:style)) +
        %[/>]
    else
      if content&.content_type == 'text/css'
        %[<link rel="stylesheet" type="text/css"] +
          attr_str(:href, arg(:href), full_path) +
          %[/>]
      elsif content&.content_type == 'application/javascript'
        %[<script] +
          attr_str(:src, arg(:src), full_path) +
          %[/></script>]
      else
        "<!-- unknown asset: #{argv1} -->"
      end
    end
  end
end

Liquid::Template.register_tag('asset', AssetTag)
