# frozen_string_literal: true

Scribo.setup do |config|
  config.base_controller = '::ApplicationController'

  # Make it less verbose
  if Rails.env.test?
    config.logger = Logger.new('/dev/null')
    config.logger.level = Logger::FATAL
  else
    config.logger = Rails.logger
    config.logger.level = Logger::DEBUG
  end

  config.scribable_for_request = lambda do |_request|
    Account.current
  end

  config.scribable_objects = lambda do
    return [] unless Account.current

    [Account.current]
  end
end
