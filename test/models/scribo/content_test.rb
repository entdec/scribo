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

    test 'creating of content uploads assets into storage' do
      @site = Scribo::Site.create!

      data = File.read(File.expand_path('../../files/150.png', __dir__))
      subject = @site.contents.create!(kind: 'asset', path: '150.png', data: data)

      assert_equal '/150.png', subject.full_path
      refute subject.data
      assert subject.asset.attached?
      assert_equal data, subject.asset.download.force_encoding('utf-8')
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

    test 'sets full path correctly for collection and document smurrefluts.md' do
      @site = Scribo::Site.create!(properties: { 'collections': { 'docs': { 'output': true } } })
      folder = @site.contents.create!(kind: 'folder', path: '_docs')
      subject = @site.contents.create!(parent: folder, kind: 'text', path: 'smurrefluts.md', data: '# smurrefluts')

      assert subject.part_of_collection?
      assert_equal '/docs/smurrefluts.md', subject.full_path
    end

    test 'sets full path correctly for _post and post 2020-11-01-test.md' do
      @site = Scribo::Site.create!
      blah = @site.contents.create!(kind: 'folder', path: 'blah')
      folder = @site.contents.create!(parent: blah, kind: 'folder', path: '_posts')
      subject = @site.contents.create!(parent: folder, kind: 'text', path: '2020-11-01-test.md', data: '# something')

      refute subject.part_of_collection?
      assert_equal '/blah/_posts/2020-11-01-test.md', subject.full_path
    end

    test 'search based on any word' do
      @site = Scribo::Site.create!
      page1 = @site.contents.create!(kind: 'text', path: 'page1.md', data: 'this is the amazing page 1')
      page2 = @site.contents.create!(kind: 'text', path: 'page2.md', data: 'my page is amazing')
      page3 = @site.contents.create!(kind: 'text', path: 'page3.md', data: 'hello page')
      page4 = @site.contents.create!(kind: 'text', path: 'page4.md', data: 'bye bye bye')

      contents = @site.contents.search('amazing | page')
      assert_equal 3, contents.size
      assert_equal [page1, page2, page3].sort, contents.sort
    end

    test 'search based on all words' do
      @site = Scribo::Site.create!
      page1 = @site.contents.create!(kind: 'text', path: 'page1.md', data: 'this is the amazing page 1')
      page2 = @site.contents.create!(kind: 'text', path: 'page2.md', data: 'my page is amazing')
      page3 = @site.contents.create!(kind: 'text', path: 'page3.md', data: 'hello page')
      page4 = @site.contents.create!(kind: 'text', path: 'page4.md', data: 'bye bye bye')

      contents = @site.contents.search('amazing & page')
      assert_equal 2, contents.size
      assert_equal [page1, page2].sort, contents.sort
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
      subject.update(properties: { layout: Scribo::Utility.file_name(scribo_contents(:layout).path) })
      assert_not subject.valid?
    end

    test 'find the excerpt' do
      subject = Scribo::Content.new(kind: 'text', path: 'hello.md')
      subject.data_with_frontmatter = "# Hello\n\nSmurrefluts"
      assert_equal "<p>Smurrefluts</p>\n", subject.excerpt
    end

    test 'content properties with site defaults' do
      skip

      @site = Scribo::Site.create!(properties: { 'defaults': ['scope': { path: 'section' }, 'values': { layout: 'specific-layout' }] })
      folder = @site.contents.create!(kind: 'folder', path: 'section')
      subject = @site.contents.create!(parent: folder, kind: 'text', path: 'smurrefluts.md', data: '# smurrefluts')

      assert_equal({ 'layout' => 'specific-layout' }, subject.defaults)
      assert_equal 'specific-layout', subject.properties['layout']
    end

    test 'content properties with site defaults, out of scope' do
      @site = Scribo::Site.create!(properties: { 'defaults': ['scope': { path: 'section' }, 'values': { layout: 'specific-layout' }] })
      folder = @site.contents.create!(kind: 'folder', path: 'blasection')
      subject = @site.contents.create!(parent: folder, kind: 'text', path: 'smurrefluts.md', data: '# smurrefluts')

      assert_equal({}, @site.defaults_for(subject))
      assert_nil subject.properties['layout']
    end

    test 'renders simple text with {%raw%} usage' do
      markdown = <<~MARKDOWN
        {%raw%}
        ```markdown
        <ul>
        {%for photo in site.data.photos%}
        <li>{{photo.url}}</li>
        {%endfor%}
        </ul>
        ```
        {%endraw%}
      MARKDOWN

      output = <<~OUTPUT

        <div class=\"language-markdown highlighter-rouge\"><div class=\"highlight\"><pre class=\"highlight\"><code><span class=\"nt\">&lt;ul&gt;</span>
        {%for photo in site.data.photos%}
        <span class=\"nt\">&lt;li&gt;</span>{{photo.url}}<span class=\"nt\">&lt;/li&gt;</span>
        {%endfor%}
        <span class=\"nt\">&lt;/ul&gt;</span>
        </code></pre></div></div>

      OUTPUT

      subject = Scribo::Content.create(kind: 'text', data: markdown, path: 'test.md')
      result = Scribo::ContentRenderService.new(subject, self).call

      assert_equal output, result
    end

    test 'finds all alternatives path for /' do
      subject = Scribo::Content.search_paths_for('/')

      assert_equal %w[/ /index /index.htm /index.html /index.htmlx /index.htx /index.link /index.markdown /index.md /index.mkd /index.shtml /index.slim], subject.sort
    end

    test 'finds all alternatives path for /index' do
      subject = Scribo::Content.search_paths_for('/index')

      assert_equal %w[/index /index.htm /index.html /index.htmlx /index.htx /index.link /index.markdown /index.md /index.mkd /index.shtml /index.slim /index/], subject.sort
    end

    test 'finds all alternatives path for /docs/' do
      subject = Scribo::Content.search_paths_for('/docs/')

      assert_equal %w[/docs /docs.htm /docs.html /docs.htmlx /docs.htx /docs.link /docs.markdown /docs.md /docs.mkd /docs.shtml /docs.slim /docs/ /docs/index /docs/index.htm /docs/index.html /docs/index.htmlx /docs/index.htx /docs/index.link /docs/index.markdown /docs/index.md /docs/index.mkd /docs/index.shtml /docs/index.slim], subject.sort
    end

    test 'finds all alternatives path for /blog/2/' do
      subject = Scribo::Content.search_paths_for('/blog/2/')
      assert_equal %w[/blog /blog.htm /blog.html /blog.htmlx /blog.htx /blog.link /blog.markdown /blog.md /blog.mkd /blog.shtml /blog.slim /blog/ /blog/index /blog/index.htm /blog/index.html /blog/index.htmlx /blog/index.htx /blog/index.link /blog/index.markdown /blog/index.md /blog/index.mkd /blog/index.shtml /blog/index.slim], subject.sort
    end
  end
end
