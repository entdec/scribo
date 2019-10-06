# frozen_string_literal: true

require 'test_helper'

module Scribo
  class ContentTest < ActiveSupport::TestCase
    test 'renders simple text content' do
      subject = scribo_contents(:index)
      result = Scribo::ContentRenderService.new(subject, self).call

      assert_equal 'Test index', result
    end

    test 'renders content with layout' do
      subject = scribo_sites(:main).contents.create(kind: 'text', path: '/test', data: 'test', content_type: 'text/html', layout: scribo_contents(:layout))
      result = Scribo::ContentRenderService.new(subject, self).call

      assert_equal 'layouttestlayout', result
    end

    test 'renders content_for within layout' do
      layout1 = scribo_sites(:main).contents.create(kind: 'text', path: '_layouts/layout1', data: "<section>{%yield 'section'%}</section><body>{%yield%}</body>", content_type: 'text/html')
      subject = scribo_sites(:main).contents.create(kind: 'text', path: '/test', data: "{%content_for 'section'%}bla{%endcontent_for%}test", content_type: 'text/html', layout: layout1)

      result = Scribo::ContentRenderService.new(subject, self).call

      assert_equal '<section>bla</section><body>test</body>', result
    end

    test 'renders content_for within nested layout' do
      layout1 = scribo_sites(:main).contents.create(kind: 'text', path: '_layouts/layout1', data: "<section>{%yield 'section'%}</section><body>{%yield%}</body>", content_type: 'text/html')
      layout2 = scribo_sites(:main).contents.create(kind: 'text', path: '_layouts/layout2', data: '<main>{%yield%}</main>', content_type: 'text/html', layout: layout1)
      subject = scribo_sites(:main).contents.create(kind: 'text', path: '/test', data: "{%content_for 'section'%}bla{%endcontent_for%}test", content_type: 'text/html', layout: layout2)

      result = Scribo::ContentRenderService.new(subject, self).call

      assert_equal '<section>bla</section><body><main>test</main></body>', result
    end


    test 'renders content_for within layout, registers not available in template' do
      layout1 = scribo_sites(:main).contents.create(kind: 'text', path: '_layouts/layout1', data: "{{_yield['']}}<section>{%yield 'section'%}</section><body>{%yield%}</body>{{_yield['section']}}", content_type: 'text/html')
      subject = scribo_sites(:main).contents.create(kind: 'text', path: '/test', data: "{%content_for 'section'%}bla{%endcontent_for%}test", content_type: 'text/html', layout: layout1)

      result = Scribo::ContentRenderService.new(subject, self).call

      assert_equal '<section>bla</section><body>test</body>', result
    end

    test 'layout cant be current content' do
      subject = scribo_contents(:index)
      subject.layout = scribo_contents(:index)
      assert_not subject.valid?
    end

    test 'find the excerpt' do
      subject = Scribo::Content.new(kind: 'text', path: 'hello.md')
      subject.data_with_frontmatter = "# Hello\n\nSmurrefluts"
      assert_equal "<h1 id=\"hello\">Hello</h1>\n", subject.excerpt
    end

  end
end
