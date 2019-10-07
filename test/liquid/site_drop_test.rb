# frozen_string_literal: true

require 'test_helper'

class SiteDropTest < ActiveSupport::TestCase
  test 'renders posts' do
    contents       = scribo_sites(:main).contents

    posts_folder = contents.create!(path: '_posts', kind: 'folder')

    subject = contents.create!(path: '/home.html', kind: 'text', data: '{%if site.posts.size > 0%}{%for post in site.posts%}{{post.title}}{%endfor%}{%endif%}')
    post1   = contents.create!(parent: posts_folder, path: 'post1.html', kind: 'text', data: 'post1', properties: { title: "my post1", date: '2019-05-24T21:03:36.000+05:30' })
    post2   = contents.create!(parent: posts_folder, path: 'post2.html', kind: 'text', data: 'post2', properties: { title: "my post2", date: '2019-05-23T21:03:36.000+05:30' })

    result = Scribo::ContentRenderService.new(subject, nil).call

    assert_equal 'my post1my post2', result
  end
end
