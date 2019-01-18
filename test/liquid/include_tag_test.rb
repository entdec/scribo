# frozen_string_literal: true

require 'test_helper'

class IncludeTagTest < ActiveSupport::TestCase
  test 'does not include non-published content from current site' do
    scribo_buckets(:main).contents.create(identifier: 'menu', kind: 'text', data: 'included content', content_type: 'text/html')
    subject = scribo_buckets(:main).contents.create(kind: 'text', data: "|{%include 'menu'%}|", content_type: 'text/html')

    result = subject.render

    assert_equal '||', result
  end

  test 'includes content from current site' do
    scribo_buckets(:main).contents.create(state: 'published', identifier: 'menu', kind: 'text', data: 'included content', content_type: 'text/html')
    subject = scribo_buckets(:main).contents.create(kind: 'text', data: "|{%include 'menu'%}|", content_type: 'text/html')

    result = subject.render

    assert_equal '|included content|', result
  end

  test 'does not include content from other site' do
    scribo_buckets(:second).contents.create(state: 'published', identifier: 'menu', kind: 'text', data: 'included content', content_type: 'text/html')
    subject = scribo_buckets(:main).contents.create(kind: 'text', data: "|{%include 'menu'%}|", content_type: 'text/html')

    result = subject.render

    assert_equal '||', result
  end

  test 'included content receives context passed from subject' do
    scribo_buckets(:main).contents.create(state: 'published', identifier: 'menu', kind: 'text', data: 'hello {{dummy.dummy_attr}}', content_type: 'text/html')
    subject = scribo_buckets(:main).contents.create(kind: 'text', data: "{{dummy.dummy_attr}}|{%include 'menu'%}|", content_type: 'text/html')

    d = DummyObject.new('dummy')
    result = subject.render('dummy' => d)

    assert_equal 'dummy|hello dummy|', result
  end

  test 'included content receives context passed from subject as well as assigns from tag' do
    scribo_buckets(:main).contents.create(state: 'published', identifier: 'menu', kind: 'text', data: 'hello {{dummy.dummy_attr}} {{name}}', content_type: 'text/html')
    subject = scribo_buckets(:main).contents.create(kind: 'text', data: "{{dummy.dummy_attr}}|{%include 'menu' name='bob'%}|{{name}}", content_type: 'text/html')

    d = DummyObject.new('dummy')
    result = subject.render('dummy' => d)

    assert_equal 'dummy|hello dummy bob|', result
  end
end
