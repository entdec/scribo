# frozen_string_literal: true

require 'test_helper'

class HelperTagTest < ActiveSupport::TestCase
  test 'allows to call helpers' do
    d = DummyObject.new('dummy')
    template_data = "{%helper content_tag 'p' 'Hello world'%}"

    template = Liquid::Template.parse(template_data)
    result = template.render({ 'dummy' => d }, registers: { 'controller' => ApplicationController.new })
    assert_equal '<p>Hello world</p>', result
  end

  test 'allows to call url helpers' do
    d = DummyObject.new('dummy')
    template_data = '{%helper new_accounts_path%}'

    template = Liquid::Template.parse(template_data)
    result = template.render({ 'dummy' => d }, registers: { 'controller' => ApplicationController.new })
    assert_equal '/accounts/new', result
  end

  test 'allows to call url helpers, with url' do
    d = DummyObject.new('dummy')
    template_data = "{%helper new_accounts_url host='www.example.com'%}"

    template = Liquid::Template.parse(template_data)
    result = template.render({ 'dummy' => d }, registers: { 'controller' => ApplicationController.new })
    assert_equal 'http://www.example.com/accounts/new', result
  end

  test 'allows to call url helpers, with url from variable' do
    d = DummyObject.new('dummy')
    template_data = '{%helper new_accounts_url host=host%}'

    template = Liquid::Template.parse(template_data)
    result = template.render({ 'dummy' => d, 'host' => 'www.example.com' }, registers: { 'controller' => ApplicationController.new })
    assert_equal 'http://www.example.com/accounts/new', result
  end
end
