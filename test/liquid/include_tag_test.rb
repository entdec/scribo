# frozen_string_literal: true

require 'test_helper'

class IncludeTagTest < ActiveSupport::TestCase
  test 'does not include non-published content from current site' do
    contents       = scribo_sites(:main).contents
    include_folder = contents.create!(path: '_includes', kind: 'folder')
    include_menu   = contents.create!(parent: include_folder, path: 'menu', kind: 'text', data: 'included content', content_type: 'text/html', properties: { published: false })
    subject        = contents.create!(path: '/test.html', kind: 'text', data: "|{%include 'menu'%}|", content_type: 'text/html')

    result = Scribo::ContentRenderService.new(subject, self).call

    assert_equal '||', result
  end

  test 'includes content from current site' do
    contents       = scribo_sites(:main).contents
    include_folder = contents.create!(path: '_includes', kind: 'folder')
    include_menu   = contents.create!(parent: include_folder, path: 'menu', kind: 'text', data: 'included content', content_type: 'text/html')
    subject        = contents.create!(path: '/test.html', kind: 'text', data: "|{%include 'menu'%}|", content_type: 'text/html')

    result = Scribo::ContentRenderService.new(subject, self).call

    assert_equal '|included content|', result
  end

  test 'includes identiefied content from current site' do
    contents       = scribo_sites(:main).contents
    include_menu   = contents.create!(path: '_menu', kind: 'text', data: 'included content', content_type: 'text/html')
    subject        = contents.create!(path: '/test.html', kind: 'text', data: "|{%include 'menu'%}|", content_type: 'text/html')

    result = Scribo::ContentRenderService.new(subject, self).call

    assert_equal '|included content|', result
  end


  test 'does not include content from other site' do
    include_folder = scribo_sites(:second ).contents.create!(path: '_includes', kind: 'folder')
    scribo_sites(:second).contents.create!(parent: include_folder, path: 'menu', kind: 'text', data: 'included content', content_type: 'text/html')
    subject = scribo_sites(:main).contents.create!(path: '/test.html', kind: 'text', data: "|{%include 'menu'%}|", content_type: 'text/html')

    result = Scribo::ContentRenderService.new(subject, self).call

    assert_equal '||', result
  end

  test 'included content receives context passed from subject' do
    include_folder = scribo_sites(:main).contents.create!(path: '_includes', kind: 'folder')
    scribo_sites(:main).contents.create!(parent: include_folder, path: 'menu', kind: 'text', data: 'hello {{dummy.dummy_attr}}', content_type: 'text/html')
    subject = scribo_sites(:main).contents.create!(path: '/test.html', kind: 'text', data: "{{dummy.dummy_attr}}|{%include 'menu'%}|", content_type: 'text/html')

    @dummy = DummyObject.new('dummy')
    result = Scribo::ContentRenderService.new(subject, self).call

    assert_equal 'dummy|hello dummy|', result
  end

  test 'included content receives context passed from subject as well as assigns from tag' do
    include_folder = scribo_sites(:main).contents.create!(path: '_includes', kind: 'folder')
    scribo_sites(:main).contents.create!(parent: include_folder, path: 'menu', kind: 'text', data: 'hello {{dummy.dummy_attr}} {{name}}', content_type: 'text/html')
    subject = scribo_sites(:main).contents.create!(path: '/test.html', kind: 'text', data: "{{dummy.dummy_attr}}|{%include 'menu' name:'bob'%}|{{name}}", content_type: 'text/html')

    @dummy = DummyObject.new('dummy')
    result = Scribo::ContentRenderService.new(subject, self).call

    assert_equal 'dummy|hello dummy bob|', result
  end
end
