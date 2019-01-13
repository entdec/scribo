# frozen_string_literal: true

# Asset tag
#
# {%asset 'test.png'%}
# {%asset 'test.png' height="72px"%}
#
# Not really used but one could pass options with json
# {%asset 'test.png' style="height: 72px;" {"style":"test"}%}
class AssetTag < Liquid::Tag
  SYNTAX = /(\"|\')(?<name>[^\"\']+)(\"|\')\s?(?<attrs>(([a-z_]+)\=\"([^\"]*)\")\s?)*(?<json>{.*})?/

  def initialize(tag_name, markup, options)
    super
    if markup =~ SYNTAX
      @name = Regexp.last_match[:name]
      @json = Regexp.last_match[:json]
      @json = JSON.parse(@json) if @json
      @attrs = Regexp.last_match[:attrs]
    else
      raise SyntaxError, "Syntax Error in 'asset' - Valid syntax: asset 'name' height='70' {'style': 'test'}, you passed: #{markup}"
    end

  end

  def render(context)
    content = Scribo::Content.named(@name).first
    case content.content_type_group
    when 'image'
      path = content.path ? content.path : context.registers['controller'].helpers.content_url(content)
      %[<img src="#{path}" alt="#{content.title||content.name}" title="#{content.caption||content.name}" #{@attrs}"/>]
    end
  end
end

Liquid::Template.register_tag('asset', AssetTag)
