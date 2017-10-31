# frozen_string_literal: true

# Asset tag
#
# {% asset 'test.png' %}
class AssetTag < Liquid::Tag
  SYNTAX = /(#{Liquid::QuotedFragment})/o

  def initialize(tag_name, markup, options)
    super
    if markup =~ SYNTAX
      @name = Liquid::Expression.parse(Regexp.last_match[1])
    else
      raise SyntaxError, "Syntax Error in 'asset' - Valid syntax: asset 'name'"
    end
  end

  def render(_context)
    content = Content.named(@name).first
    case content.content_type_group
    when 'image'
      %[<img src="#{content.path}" alt="#{content.title}" title="#{content.caption}"/>]
    end
  end
end

Liquid::Template.register_tag('asset', AssetTag)
