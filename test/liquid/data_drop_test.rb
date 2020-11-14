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
end
