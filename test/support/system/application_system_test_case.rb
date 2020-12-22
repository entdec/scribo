# frozen_string_literal: true

# Change the Capybara server host and port based on ENV variables
Capybara.server_host = ENV['CAPYBARA_SERVER_HOST'] if ENV.include?('CAPYBARA_SERVER_HOST')
Capybara.server_port = ENV['CAPYBARA_SERVER_PORT'].to_i if ENV.include?('CAPYBARA_SERVER_PORT')
Capybara.server_port = nil if ENV['CAPYBARA_SERVER_PORT'] == '0'
class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :cuprite

  class << self
    # Use our `Capybara.save_path` to store screenshots with other capybara artifacts
    # (Rails screenshots path is not configurable https://github.com/rails/rails/blob/49baf092439fc74fc3377b12e3334c3dd9d0752f/actionpack/lib/action_dispatch/system_testing/test_helpers/screenshot_helper.rb#L79)
    def absolute_image_path
      Rails.root.join("#{Capybara.save_path}/screenshots/#{image_name}.png")
    end

    # Make failure screenshots compatible with multi-session setup.
    # That's where we use Capybara.last_used_session introduced before.
    def take_screenshot
      return super unless Capybara.last_used_session

      Capybara.using_session(Capybara.last_used_session) { super }
    end
  end

  setup do
    # return if page.server.nil?

    app_port          = Capybara.server_port || page.server.port
    Capybara.app_host = "http://#{Capybara.server_host}:#{app_port}"
    Capybara.server = :puma

    # Capybara.default_max_wait_time = 5
  end

  def browser_action
    page.driver.browser.action
  end

  def send_keys(keys)
    browser_action.send_keys(keys).perform
  end

  def hover(element)
    element = page.find(element) if element.is_a?(String)

    browser_action.move_to(element.native).perform
  end
end
