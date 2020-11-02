# ##frozen_string_literal: true

require 'test_helper'

module Scribo
  class ContentTest < ActiveSupport::TestCase
    test 'sets full path correctly for root content and path index.html' do
      @site = Scribo::Site.create!
      subject = @site.contents.create!(kind: 'text', path: 'index.html', data: 'something')

      assert_equal '/index.html', subject.full_path
    end

    test 'sets full path correctly for root content and path index.md' do
      @site = Scribo::Site.create!
      subject = @site.contents.create!(kind: 'text', path: 'index.md', data: 'something')

      assert_equal '/index.md', subject.full_path
    end

    test 'sets full path correctly for subfolder and path index.html' do
      @site = Scribo::Site.create!
      folder = @site.contents.create!(kind: 'folder', path: 'smurrefluts')
      subject = @site.contents.create!(parent: folder, kind: 'text', path: 'index.html', data: 'something')

      assert_equal '/smurrefluts/index.html', subject.full_path
    end

    test 'sets full path correctly for post and post 2020-11-01-test.md' do
      @site = Scribo::Site.create!
      folder = @site.contents.create!(kind: 'folder', path: '_posts')
      subject = @site.contents.create!(parent: folder, kind: 'text', path: '2020-11-01-test.md', data: '# something')

      assert_equal '/2020/11/01/test.md', subject.full_path
    end

    test 'renders simple text content' do
      subject = scribo_contents(:index)
      result = Scribo::ContentRenderService.new(subject, self).call

      assert_equal 'Test index', result
    end

    test 'renders content with layout' do
      subject = scribo_sites(:main).contents.create(kind: 'text', path: '/test.html', data: 'test', properties: { layout: 'layout' })
      result = Scribo::ContentRenderService.new(subject, self).call

      assert_equal 'layouttestlayout', result
    end

    test 'renders content_for within layout' do
      layout1 = scribo_sites(:main).contents.create(kind: 'text', path: 'layout1.html', full_path: '/_layouts/layout1.html', data: "<section>{%yield 'section'%}</section><body>{%yield%}</body>", parent: scribo_contents(:layout_folder))
      subject = scribo_sites(:main).contents.create(kind: 'text', path: 'test.html', full_path: '/test.html', data: "{%content_for 'section'%}bla{%endcontent_for%}test", properties: { layout: 'layout1' })
      result = Scribo::ContentRenderService.new(subject, self).call

      assert_equal '<section>bla</section><body>test</body>', result
    end

    test 'renders content_for within nested layout' do
      layout1 = scribo_sites(:main).contents.create(kind: 'text', path: 'layout1.html', full_path: '/_layouts/layout1.html', data: "<section>{%yield 'section'%}</section><body>{%yield%}</body>", parent: scribo_contents(:layout_folder))
      layout2 = scribo_sites(:main).contents.create(kind: 'text', path: 'layout2.html', full_path: '/_layouts/layout2.html', data: '<main>{%yield%}</main>', properties: { layout: 'layout1' }, parent: scribo_contents(:layout_folder))
      subject = scribo_sites(:main).contents.create(kind: 'text', path: 'test.html', full_path: '/test.html', data: "{%content_for 'section'%}bla{%endcontent_for%}test", properties: { layout: 'layout2' })

      result = Scribo::ContentRenderService.new(subject, self).call

      assert_equal '<section>bla</section><body><main>test</main></body>', result
    end

    test 'renders content_for within layout, registers not available in template' do
      layout1 = scribo_sites(:main).contents.create(kind: 'text', path: 'layout1.html', full_path: '/_layouts/layout1.html', data: "{{_yield['']}}<section>{%yield 'section'%}</section><body>{%yield%}</body>{{_yield['section']}}", parent: scribo_contents(:layout_folder))
      subject = scribo_sites(:main).contents.create(kind: 'text', path: 'test.html', full_path: '/test.html', data: "{%content_for 'section'%}bla{%endcontent_for%}test", properties: { layout: 'layout1' })

      result = Scribo::ContentRenderService.new(subject, self).call

      assert_equal '<section>bla</section><body>test</body>', result
    end

    test 'layout cant be current content' do
      subject = scribo_contents(:layout)
      subject.properties = {}
      subject.properties['layout'] = Scribo::Utility.file_name(scribo_contents(:layout).path)
      assert_not subject.valid?
    end

    test 'find the excerpt' do
      subject = Scribo::Content.new(kind: 'text', path: 'hello.md')
      subject.data_with_frontmatter = "# Hello\n\nSmurrefluts"
      assert_equal "<p>Smurrefluts</p>\n", subject.excerpt
    end
  end
end
