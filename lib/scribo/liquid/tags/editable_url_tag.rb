# frozen_string_literal: true

# Makes content available for editing, basically adds the right attributes
#
# == Basic usage:
#    <div {%editable%} data-editable-id='fiets'></div>
#
class EditableUrlTag < LiquorTag
  def render(context)
    super

    content = context.registers['content']

    # FIXME: Use url helpers
    %[/scribo/sites/#{content.site.id}/contents/#{content.id}/parts]
  end
end

Liquid::Template.register_tag('editable_url', EditableUrlTag)
