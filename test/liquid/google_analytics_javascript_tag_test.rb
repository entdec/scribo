# frozen_string_literal: true

require 'test_helper'

class GoogleAnalyticsJavascriptTagTest < ActiveSupport::TestCase
  test 'works with plain passed string' do
    rails_env_stub :production do
      d = DummyObject.new('dummy')
      template_data = "{%google_analytics_javascript 'foobar'%}"

      template = Liquid::Template.parse(template_data)
      result   = template.render('dummy' => d)
      assert_includes result, 'www.google-analytics.com'
    end
  end

  test 'works with passed variable' do
    rails_env_stub :production do
      d = DummyObject.new('dummy')
      template_data = '{% google_analytics_javascript dummy.dummy_attr %}'

      template = Liquid::Template.parse(template_data)
      result   = template.render('dummy' => d)
      assert_includes result, 'www.google-analytics.com'
    end
  end
end
