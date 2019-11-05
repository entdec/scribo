# frozen_string_literal: true

# Full-text searches content, in both content and properties
#
# == Basic usage:
#    {%search q%}
#    {{search|size}} results
#    {%endsearch%}
#
# Note: It will only look at published content
class SearchTag < LiquorBlock
  def render(context)
    super

    current_content = context.registers['content']
    request = context.registers['controller'].request

    contents = current_content.site.contents.published.search(request.params[argv1])

    result = ''
    context.stack do
      context['results'] = contents.map { |content| Scribo::ContentDrop.new(content) }
      result += render_body
    end
    result
  end
end

Liquid::Template.register_tag('search', SearchTag)
