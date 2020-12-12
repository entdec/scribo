# frozen_string_literal: true

require 'test_helper'

class DataDropTest < ActiveSupport::TestCase
  test 'allows to iterate over posts' do
    contents = scribo_sites(:main).contents

    data_folder = contents.create!(path: '_data', kind: 'folder')

    data = [{ 'title' => 'Getting Started', 'docs' => %w[installation setup navigation footer posts docs comments analytics] },
            { 'title' => 'Theme Features', 'docs' => %w[hero boxes featured videos faq team cta changelog contact media toc alerts] },
            { 'title' => 'Customization', 'docs' => %w[translation customize development sources] },
            { 'title' => 'Help', 'docs' => ['support'] }]

    contents.create!(path: 'navigation_docs.json', kind: 'text', data: JSON.dump(data), parent: data_folder)

    subject = contents.create!(path: 'navigation_docs.json', kind: 'text', data: '{%for section in site.data.navigation_docs %}{% for doc in section.docs %}{{doc}}{%endfor%}{%endfor%}')

    result = Scribo::ContentRenderService.new(subject, nil).call

    assert_equal 'installationsetupnavigationfooterpostsdocscommentsanalyticsheroboxesfeaturedvideosfaqteamctachangelogcontactmediatocalertstranslationcustomizedevelopmentsourcessupport', result
  end

  test 'allows to iterate over posts in csv' do
    contents = scribo_sites(:main).contents

    data_folder = contents.create!(path: '_data', kind: 'folder')

    data = "file;text\r\ntest.jpg;\"Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.\"\r\n"

    contents.create!(path: 'fotos.csv', kind: 'text', data: data, parent: data_folder)

    subject = contents.create!(path: 'test.html', kind: 'text', data: '{%for foto in site.data.fotos %}{{foto.file}}{%endfor%}')

    result = Scribo::ContentRenderService.new(subject, nil).call

    assert_equal 'test.jpg', result
  end
end
