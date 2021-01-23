# frozen_string_literal: true

require 'test_helper'

class PaginatorDropTest < ActiveSupport::TestCase
  setup do
    @site = Scribo::Site.create!
    posts_folder = @site.contents.create!(path: '_posts', kind: 'folder')
    creation_time = 1.day.ago
    25.times do |i|
      @site.contents.create!(kind: 'text', path: "2020-11-17-post#{i + 1}.md", data_with_frontmatter: "---\ntitle: Post #{i + 1}\n---\n# Post #{i + 1}\n\nSome description for post #{i + 1}", parent: posts_folder, created_at: creation_time)
      creation_time += 1.minute
    end
  end
  test 'should report page' do
    subject = create_page('{{paginator.page}}')
    result = Scribo::ContentRenderService.new(subject, context(3), { site: @site }).call
    assert_equal '3', result
  end

  test 'should report next page' do
    subject = create_page('{{paginator.next_page}}')
    result = Scribo::ContentRenderService.new(subject, context(3), { site: @site }).call
    assert_equal '4', result.force_encoding('utf-8')
  end

  test 'should report nil if no next page' do
    subject = create_page('{{paginator.next_page}}')
    result = Scribo::ContentRenderService.new(subject, context(5), { site: @site }).call
    assert_equal '', result.force_encoding('utf-8')
  end

  test 'should report nil if no previous page' do
    subject = create_page('{{paginator.previous_page}}')
    result = Scribo::ContentRenderService.new(subject, context(1), { site: @site }).call
    assert_equal '', result.force_encoding('utf-8')
  end

  test 'should report correct previous page path' do
    subject = create_page('{{paginator.previous_page_path}}')
    result = Scribo::ContentRenderService.new(subject, context(2), { site: @site }).call
    assert_equal '/blog/1/', result.force_encoding('utf-8')
  end

  test 'should report no previous page path' do
    subject = create_page('{{paginator.previous_page_path}}')
    result = Scribo::ContentRenderService.new(subject, context(1), { site: @site }).call
    assert_equal '', result.force_encoding('utf-8')
  end

  test 'should report correct next page path' do
    subject = create_page('{{paginator.next_page_path}}')
    result = Scribo::ContentRenderService.new(subject, context(2), { site: @site }).call
    assert_equal '/blog/3/', result.force_encoding('utf-8')
  end

  test 'should report no next page path' do
    subject = create_page('{{paginator.next_page_path}}')
    result = Scribo::ContentRenderService.new(subject, context(5), { site: @site }).call
    assert_equal '', result.force_encoding('utf-8')
  end

  test 'should show second 5 posts' do
    subject = create_page('{%for post in paginator.posts%}{{post.title}}{%endfor%}')
    result = Scribo::ContentRenderService.new(subject, context(2), { site: @site }).call
    assert_equal 'Post 6Post 7Post 8Post 9Post 10', result.force_encoding('utf-8')
  end

  test 'should show second 6 posts' do
    @site.properties = { 'paginate' => 6 }
    subject = create_page('{{paginator.per_page}}:{%for post in paginator.posts%}{{post.title}}{%endfor%}')
    result = Scribo::ContentRenderService.new(subject, context(2), { site: @site }).call
    assert_equal '6:Post 7Post 8Post 9Post 10Post 11Post 12', result.force_encoding('utf-8')
  end

  private

  def create_page(data)
    @site.contents.create!(path: '/blog.html', kind: 'text', data: data)
  end

  def context(page)
    ac = ApplicationController.new
    ac.request = ActionDispatch::Request.new({ 'ORIGINAL_FULLPATH' => "/blog/#{page}/" })
    ac
  end
end
