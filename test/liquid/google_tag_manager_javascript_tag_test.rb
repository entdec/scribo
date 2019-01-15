# frozen_string_literal: true

require 'test_helper'

class DummyObjectDrop < Liquid::Drop
  delegate :dummy_attr, to: :@object

  def initialize(object)
    @object = object
  end
end

class DummyObject
  attr_accessor :dummy_attr

  def initialize(da)
    @dummy_attr = da
  end

  def to_liquid
    DummyObjectDrop.new(self)
  end
end

class GoogleTagManagerJavascriptTagTest < ActiveSupport::TestCase
  test 'works with plain passed string' do
    rails_env_stub :production do
      d = DummyObject.new('dummy')
      template_data = "{%google_tag_manager_javascript 'GTM-XXXXXXX'%}"

      template = Liquid::Template.parse(template_data)
      result   = template.render('dummy' => d)
      assert_includes result, 'www.googletagmanager.com'
    end
  end

  test 'works with passed variable' do
    rails_env_stub :production do
      d = DummyObject.new('dummy')
      template_data = '{%google_tag_manager_javascript dummy.dummy_attr%}'

      template = Liquid::Template.parse(template_data)
      result   = template.render('dummy' => d)
      assert_includes result, 'www.googletagmanager.com'
    end
  end
end
