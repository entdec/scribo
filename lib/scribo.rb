# frozen_string_literal: true

# rubocop:disable Style/ClassVars

require 'aasm'
require 'liquid'

require 'scribo/engine'
require 'scribo/action_controller_helpers'
require 'scribo/active_record_helpers'
require 'scribo/action_view_helpers'
require 'scribo/version'

module Scribo
  # Configuration
  # What should be the base controller for the admin-side
  mattr_accessor :admin_base_controller
  @@admin_base_controller = '::ApplicationController'

  # Configuration
  # What should be the base controller for the content-rendering
  mattr_accessor :base_controller
  @@base_controller = '::ApplicationController'

  mattr_accessor :supported_mime_types
  @@supported_mime_types = {
    image:    %w[image/gif image/png image/jpeg image/bmp image/webp image/svg+xml],
    text:     %w[text/plain text/html text/css text/javascript application/javascript application/json application/xml],
    audio:    %w[audio/midi audio/mpeg audio/webm audio/ogg audio/wav],
    video:    %w[video/webm video/ogg video/mp4],
    document: %w[application/msword application/vnd.ms-powerpoint application/vnd.ms-excel application/pdf application/zip],
    font:     %w[font/collection font/otf font/sfnt font/ttf font/woff font/woff2 application/font-ttf application/vnd.ms-fontobject application/font-woff],
    other:    %w[application/octet-stream]
  }

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

# rubocop:enable Style/ClassVars
