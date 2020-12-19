# frozen_string_literal: true

require 'test_helper'

class MarkdownifyFilterTest < ActiveSupport::TestCase
  test 'works with plain passed string' do
    template_data = "{{'# Hello'|markdownify}}"

    template = Liquid::Template.parse(template_data)
    result   = template.render
    assert_equal "<h1 id=\"hello\">Hello</h1>\n", result
  end
end
