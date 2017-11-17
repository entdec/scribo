# frozen_string_literal: true

# ApplicationAssets tag
#
# {% application_js %}
class ApplicationJsTag < Liquid::Tag
  def lookup(context, name)
    lookup = context
    name.split('.').each { |value| lookup = lookup[value] }
    lookup
  end

  def render(context)
    js = lookup(context.registers, 'application_js')
    "<script>#{js}</script>" if js
  end
end

Liquid::Template.register_tag('application_js', ApplicationJsTag)
