# frozen_string_literal: true

require 'test_helper'

class FormTest < ActiveSupport::TestCase
  test 'can create a form' do
    template_data = %[{%form action="/smurrefluts" method="post"%}{%endform%}]

    result = Liquor.render(template_data)
    assert_equal %[<form action="/smurrefluts" method="post"></form>], result
  end
  test 'can create a checkbox' do
    template_data = %[{%check_box name="smurrefluts" class="test"%}]

    result = Liquor.render(template_data)
    assert_equal %[<input  name="smurrefluts" value="0" class="test" type="checkbox"/>], result
  end
end
