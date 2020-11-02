# frozen_string_literal: true

require 'test_helper'

class IncludeTagTest < ActiveSupport::TestCase
  test 'does not include non-published content from current site' do
    contents       = scribo_sites(:main).contents
    include_folder = contents.create!(path: '/_includes', full_path: '/_includes', kind: 'folder')
    include_menu   = contents.create!(parent: include_folder, path: 'menu.html', kind: 'text', data: 'included content', properties: { published: false })
    subject        = contents.create!(path: '/test.html', kind: 'text', data: "|{%include 'menu'%}|")

    result = Scribo::ContentRenderService.new(subject, self).call

    assert_equal '||', result
  end

  test 'includes content from current site' do
    contents       = scribo_sites(:main).contents
    include_folder = contents.create!(path: '_includes', kind: 'folder')
    include_menu   = contents.create!(parent: include_folder, path: 'menu.html', kind: 'text', data: 'included content')
    subject        = contents.create!(path: '/test.html', kind: 'text', data: "|{%include 'menu.html'%}|")

    result = Scribo::ContentRenderService.new(subject, self).call

    assert_equal '|included content|', result
  end

  test 'does not include content from outside _includes folder in current site' do
    contents       = scribo_sites(:main).contents
    include_menu   = contents.create!(path: '_menu.html', kind: 'text', data: 'included content')
    subject        = contents.create!(path: '/test.html', kind: 'text', data: "|{%include 'menu.html'%}|")

    result = Scribo::ContentRenderService.new(subject, self).call

    assert_equal '||', result
  end

  test 'does not include content from other site' do
    include_folder = scribo_sites(:second).contents.create!(path: '_includes', kind: 'folder')
    scribo_sites(:second).contents.create!(parent: include_folder, path: 'menu', kind: 'text', data: 'included content')
    subject = scribo_sites(:main).contents.create!(path: '/test.html', kind: 'text', data: "|{%include 'menu'%}|")

    result = Scribo::ContentRenderService.new(subject, self).call

    assert_equal '||', result
  end

  test 'included content receives context passed from subject' do
    include_folder = scribo_sites(:main).contents.create!(path: '_includes', kind: 'folder')
    scribo_sites(:main).contents.create!(parent: include_folder, path: 'menu', kind: 'text', data: 'hello {{dummy.dummy_attr}}')
    subject = scribo_sites(:main).contents.create!(path: '/test.html', kind: 'text', data: "{{dummy.dummy_attr}}|{%include 'menu'%}|")

    @dummy = DummyObject.new('dummy')
    result = Scribo::ContentRenderService.new(subject, self).call

    assert_equal 'dummy|hello dummy|', result
  end

  test 'included content receives context passed from subject as well as assigns from tag' do
    include_folder = scribo_sites(:main).contents.create!(path: '_includes', kind: 'folder')
    scribo_sites(:main).contents.create!(parent: include_folder, path: 'menu', kind: 'text', data: 'hello {{dummy.dummy_attr}} {{name}}')
    subject = scribo_sites(:main).contents.create!(path: '/test.html', kind: 'text', data: "{{dummy.dummy_attr}}|{%include 'menu' name:'bob'%}|{{name}}")

    @dummy = DummyObject.new('dummy')
    result = Scribo::ContentRenderService.new(subject, self).call

    assert_equal 'dummy|hello dummy bob|', result
  end
end
