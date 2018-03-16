# frozen_string_literal: true

require 'test_helper'

class TranslateFilterTest < ActiveSupport::TestCase
  test 'will allow translations' do
    I18n.stub(:t, 'smurrefluts') do
      template_data = "{{ '.dummy' | translate 'en' }}"

      template = Liquid::Template.parse(template_data)
      result   = template.render
      assert_not_includes result, 'translation missing'
      assert_includes result, 'smurrefluts'
    end
  end
end
