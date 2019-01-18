# frozen_string_literal: true

Scribo.setup do |config|
  config.base_controller = '::ApplicationController'
  config.logger = Logger.new('/dev/null')
  config.bucket_for_hostname = lambda do |host_name, purpose = :site|
    Account.find_by(name: 'One').buckets.purposed(purpose).first
  end
end
