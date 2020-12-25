require 'system_helper'

class ThemeTest < ApplicationSystemTestCase
  # include TestHelpers::System::WebHelper
  include CupriteHelpers

  test 'viewing the index' do
    visit scribo.root_path
    assert_content '404 Not Found'
  end

  test 'check all themes' do
    account = Account.find_by_name('Theme')
    account.current!
    page.driver.add_headers('X-ACCOUNT' => account.id)
    Dir.glob(File.join(Dir.pwd, 'test/files/themes/*.zip')).each do |theme|
      name = File.basename(theme, File.extname(theme))
      puts name
      site = Scribo::SiteImportService.new(theme, scribable: account).call
      visit (site.baseurl || '/').to_s
      page.driver.wait_for_network_idle timeout: 120
      page.save_screenshot(File.join(Dir.pwd, "test/files/themes/#{name}.png"), full: true)
      site.destroy
    rescue Psych::DisallowedClass
    end
  end
end
