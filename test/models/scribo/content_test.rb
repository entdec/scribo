# frozen_string_literal: true

require 'test_helper'

module Scribo
  class ContentTest < ActiveSupport::TestCase
    test 'renders text content' do
      subject = scribo_contents(:index)
      result = subject.render

      assert_equal 'Test index', result
    end
  end
end
