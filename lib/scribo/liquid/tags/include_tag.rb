# frozen_string_literal: true

# Include other published content
#
# == Basic usage:
#    {%include 'navigation'}
#
# == Advanced usage:
#    {%include 'navigation' title:"Menu"}
#
# This allows you pass variables to the included content, which will only available there
#
class IncludeTag < LiquorTag
  def render(context)
    super

    content = context.registers['file_system'].read_template_file(argv1)

    result = ''
    context.stack do
      context['include'] = Scribo::IncludeDrop.new(attr_args.deep_stringify_keys)
      result += Liquor.render(content, context: context, registers: context.registers)
    end
    result
  end
end

Liquid::Template.register_tag('include', IncludeTag)
