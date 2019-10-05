
require 'test_helper'

module Scribo
  class ContentRenderServiceTest < ActiveSupport::TestCase
    test 'renders scss with includes' do
      content = Scribo::Content.located('/test.scss').first

      assert content
      subject = Scribo::ContentRenderService.new(content, {}).call

      assert_equal "body {\n  font-family: Arial;\n  font-size: 20px;\n  font-weight: bold;\n  color: #ff0000; }\n", subject
    end
  end
end