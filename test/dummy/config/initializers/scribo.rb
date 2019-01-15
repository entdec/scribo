# frozen_string_literal: true

Scribo.setup do |config|
  config.base_controller = '::ApplicationController'
  config.logger = Logger.new('/dev/null')
end
