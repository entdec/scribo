# frozen_string_literal: true

# ApplicationAssets tag
#
# == Basic usage:
#    {%application_js%}
class ApplicationJsTag < LiquorTag
  def render(context)
    super

    js = lookup(context.registers, 'application_js')
    "<script>#{js}</script>" if js
  end
end

Liquid::Template.register_tag('application_js', ApplicationJsTag)
