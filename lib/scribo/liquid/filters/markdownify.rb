# frozen_string_literal: true

module Markdownify
  def markdownify(input)
    # Easiest way at the moment
    Scribo::ContentRenderService.new(Scribo::Content.new(kind: 'text', data: input), {}, layout: false,
                                                                                         filter: 'markdown').call
  end
end

Liquid::Template.register_filter(Markdownify)
