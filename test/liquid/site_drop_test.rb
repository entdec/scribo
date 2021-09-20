# frozen_string_literal: true

require 'test_helper'

class SiteDropTest < ActiveSupport::TestCase
  test 'allows to iterate over posts' do
    contents = scribo_sites(:main).contents

    posts_folder = contents.create!(path: '_posts', kind: 'folder')

    subject = contents.create!(path: '/home.html', kind: 'text',
                               data: '{%if site.posts.size > 0%}{%for post in site.posts%}{{post.title}}{%endfor%}{%endif%}')
    post1   = contents.create!(parent: posts_folder, path: '2019-05-24-post1.html', kind: 'text', data: 'post1',
                               properties: { title: 'my post1', date: '2019-05-24T21:03:36.000+05:30' })
    post2   = contents.create!(parent: posts_folder, path: '2019-05-23-post2.html', kind: 'text', data: 'post2',
                               properties: { title: 'my post2', date: '2019-05-23T21:03:36.000+05:30' })

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
    site.properties = { collections: { staff_members: { output: true } } }

    subject = Scribo::SiteDrop.new(site)

    assert_equal %w[staff_members posts], subject.collections
  end

  test 'setting up collections, allows you to iterate over them' do
    site = scribo_sites(:collection)
    site.properties = { collections: { staff_members: { output: true } } }
    site.save

    posts_folder = site.contents.create!(path: '_posts', kind: 'folder')

    content = site.contents.create(kind: 'text',
                                   data: '{%for staff_member in site.staff_members%}{{staff_member.name}}{%endfor%}')

    assert_equal 'Jane Doe', Scribo::ContentRenderService.new(content, self).call
  end

  test 'setting up collections, allows you to iterate over them and get content' do
    site = scribo_sites(:collection)
    site.properties = { collections: { staff_members: { output: true } } }
    site.save

    content = site.contents.create(kind: 'text',
                                   data: '{%for staff_member in site.staff_members%}{{staff_member.content}}{%endfor%}')
    assert_equal "<p>Jane has worked on Jekyll for the past <em>five years</em>.</p>\n",
                 Scribo::ContentRenderService.new(content, self).call
  end
  test 'iterate over hashes in properties' do
    site = scribo_sites(:empty)
    site.properties = { social: { facebook: '1', twitter: 2 } }
    site.save

    content = site.contents.create(kind: 'text',
                                   data: '{%for platform in site.social%}{{platform[0]}}:{{platform[1]}}|{%endfor%}')

    assert_equal 'twitter:2|facebook:1|', Scribo::ContentRenderService.new(content, self).call
  end

  test 'iterate over collection and their properties' do
    # {% assign faqs = site.faqs | where: "categories", include.category %}
    site = scribo_sites(:collection)
    site.properties = { collections: { faqs: { output: false } } }
    site.save

    contents = site.contents

    faqs_folder = site.contents.create!(path: '_faqs', kind: 'folder')

    faq1   = contents.create!(parent: faqs_folder, path: '10-support.md', kind: 'text', data: 'post1',
                              properties: { title: 'support', categories: ['presale'] }, created_at: 3.hours.ago)
    faq2   = contents.create!(parent: faqs_folder, path: '20-renew.md', kind: 'text', data: 'post2',
                              properties: { title: 'renew', categories: ['presale'] }, created_at: 2.hours.ago)
    faq3   = contents.create!(parent: faqs_folder, path: '30-quit.md', kind: 'text', data: 'post3',
                              properties: { title: 'quit', categories: ['aftersale'] }, created_at: 1.hours.ago)

    content = site.contents.create(kind: 'text',
                                   data: '{% assign faqs = site.faqs | where: "categories", "presale" %}{%for faq in faqs%}{{faq.title}}{%endfor%}')
    assert_equal 'supportrenew',
                 Scribo::ContentRenderService.new(content, self).call
  end
end
