# frozen_string_literal: true

Scribo.setup do |config|
  config.base_controller = '::ApplicationController'

  # Make it less verbose
  config.logger = Logger.new('/dev/null')
  config.logger.level = Logger::FATAL

  config.site_for_uri = lambda do |_uri|
    Account.find_by(name: 'One').sites.for_path('/').first
  end

  config.scribable_objects = lambda do
    return [] unless Account.current

    [Account.current]
  end
end
