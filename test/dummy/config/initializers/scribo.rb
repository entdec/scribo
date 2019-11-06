# frozen_string_literal: true

Scribo.setup do |config|
  config.base_controller = '::ApplicationController'
  # config.logger = Logger.new('/dev/null')
  config.site_for_uri = lambda do |_uri|
    Account.find_by(name: 'One').sites.located('/').first
  end
end
