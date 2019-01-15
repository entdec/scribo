# frozen_string_literal: true

# ApplicationAssets tag
#
# == Basic usage:
#    {%application_assets%}
class ApplicationAssetsTag < ScriboTag
  def render(context)
    lookup(context.registers, 'application_assets')
  end
end

Liquid::Template.register_tag('application_assets', ApplicationAssetsTag)