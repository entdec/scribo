# frozen_string_literal: true

require 'aasm'
require 'liquid'

require 'scribo/engine'
require 'scribo/action_controller_helpers'
require 'scribo/active_record_helpers'
require 'scribo/action_view_helpers'
require 'scribo/version'

module Scribo
  # Configuration
  class Error < StandardError; end

  class Configuration
    attr_accessor :admin_authentication_module
    attr_accessor :base_controller
    attr_accessor :supported_mime_types
    attr_writer   :logger

    def initialize
      @logger = Logger.new(STDOUT)
      @logger.level = Logger::INFO
      @base_controller = '::ApplicationController'
      @supported_mime_types = {
          image:    %w[image/gif image/png image/jpeg image/bmp image/webp image/svg+xml],
          text:     %w[text/plain text/html text/css text/javascript application/javascript application/json application/xml],
          audio:    %w[audio/midi audio/mpeg audio/webm audio/ogg audio/wav],
          video:    %w[video/webm video/ogg video/mp4],
          document: %w[application/msword application/vnd.ms-powerpoint application/vnd.ms-excel application/pdf application/zip],
          font:     %w[font/collection font/otf font/sfnt font/ttf font/woff font/woff2 application/font-ttf application/vnd.ms-fontobject application/font-woff],
          other:    %w[application/octet-stream]
      }
    end

    # Config: logger [Object].
    def logger
      @logger.is_a?(Proc) ? instance_exec(&@logger) : @logger
    end
  end

  class << self
    attr_reader :config

    def setup
      @config = Configuration.new
      yield config
    end
  end

  # Include helpers
  ActiveSupport.on_load(:active_record) do
    include ActiveRecordHelpers
  end

  ActiveSupport.on_load(:action_view) do
    include ActionViewHelpers
  end

  ActiveSupport.on_load(:action_controller) do
    include ActionControllerHelpers
  end
end
