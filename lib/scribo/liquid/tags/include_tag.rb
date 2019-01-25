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
    super

    current_content = context.registers['content']
    content = current_content.bucket.contents.published.identified(argv1).first

    return unless content

    content&.render(context.environments.first.merge(attr_args.stringify_keys), context.registers)
  end
end

Liquid::Template.register_tag('include', IncludeTag)
