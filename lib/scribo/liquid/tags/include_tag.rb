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
      attr_args.stringify_keys.each { |key, value| context[key] = value }
      result += Liquor.render(content, context: context, registers: context.registers)
    end
    result
  end
end

Liquid::Template.register_tag('include', IncludeTag)
