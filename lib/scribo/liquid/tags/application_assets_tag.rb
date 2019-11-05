# frozen_string_literal: true

# ApplicationAssets tag
#
# == Basic usage:
#    {%application_assets%}
class ApplicationAssetsTag < LiquorTag
  def render(context)
    super
    lookup(context.registers, 'application_assets')
  end
end

Liquid::Template.register_tag('application_assets', ApplicationAssetsTag)
