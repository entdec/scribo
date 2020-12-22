require 'system_helper'

class ThemeTest < ApplicationSystemTestCase
  # include TestHelpers::System::WebHelper
  include CupriteHelpers

  test 'viewing the index' do
    visit scribo.root_path
    assert_content '404 Not Found'
  end

  test 'viewing agency' do
    account = Account.first
    account.current!
    Dir.glob(File.join(Dir.pwd, 'test/files/themes/*.zip')).each do |theme|
      name = File.basename(theme, File.extname(theme))
      puts "name: #{name}"
      site = Scribo::SiteImportService.new(theme, scribable: account, properties: { 'baseurl' => "/#{name}" }).call
      visit "/#{name}/"
      page.save_screenshot(File.join(Dir.pwd, "test/files/themes/#{name}.png"), full: true)
      site.destroy
    rescue Psych::DisallowedClass
    end
  end
end
