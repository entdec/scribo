# frozen_string_literal: true

require 'test_helper'

class SiteDropTest < ActiveSupport::TestCase
  test 'allows to iterate over posts' do
    contents = scribo_sites(:main).contents

    posts_folder = contents.create!(path: '_posts', kind: 'folder')

    subject = contents.create!(path: '/home.html', kind: 'text', data: '{%if site.posts.size > 0%}{%for post in site.posts%}{{post.title}}{%endfor%}{%endif%}')
    post1   = contents.create!(parent: posts_folder, path: '2019-05-24-post1.html', kind: 'text', data: 'post1', properties: { title: 'my post1', date: '2019-05-24T21:03:36.000+05:30' })
    post2   = contents.create!(parent: posts_folder, path: '2019-05-23-post2.html', kind: 'text', data: 'post2', properties: { title: 'my post2', date: '2019-05-23T21:03:36.000+05:30' })

    result = Scribo::ContentRenderService.new(subject, nil).call

    assert_equal 'my post1my post2', result
  end

  test 'allows to iterate over collections' do
    site = scribo_sites(:collection)

    subject = Scribo::SiteDrop.new(site)

    assert_equal %w[posts], subject.collections
  end

  test 'setting up collections, makes them show up in collections' do
    site = scribo_sites(:collection)
    site.properties = { 'collections': { 'staff_members': { 'output': true } } }

    subject = Scribo::SiteDrop.new(site)

    assert_equal %w[staff_members posts], subject.collections
  end

  test 'setting up collections, allows you to iterate over them' do
    site = scribo_sites(:collection)
    site.properties = { 'collections': { 'staff_members': { 'output': true } } }
    site.save

    subject = Scribo::SiteDrop.new(site)
    content = site.contents.create(kind: 'text', data: "{%for staff_member in site.staff_members%}{{staff_member.name}}{%endfor%}")

    assert_equal "Jane Doe", Scribo::ContentRenderService.new(content, self).call
  end

end
