# frozen_string_literal: true

# ApplicationAssets tag
#
# {% application_assets %}
class ApplicationAssetsTag < Liquid::Tag
  def lookup(context, name)
    lookup = context
    name.split('.').each { |value| lookup = lookup[value] }
    lookup
  end

  def render(context)
    lookup(context.registers, 'application_assets')
  end
end

Liquid::Template.register_tag('application_assets', ApplicationAssetsTag)
