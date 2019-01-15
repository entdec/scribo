# frozen_string_literal: true

# Include other published content identified by name
#
# == Basic usage:
#    {%include 'navigation'}
#
# == Advanced usage:
#    {%include 'navigation' title="Menu"}
#
# This allows you pass variables to the included content, which will only available there
#
class IncludeTag < ScriboTag
  def render(context)
    current_content = context.registers['content']

    assigns = @args.reject{|k| k == :argv1}.stringify_keys
    content = current_content.site.contents.published.identified(@argv1).first
    content&.render(context.merge(assigns), context.registers)
  end
end

Liquid::Template.register_tag('include', IncludeTag)
