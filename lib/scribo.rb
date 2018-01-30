# frozen_string_literal: true

require 'scribo/engine'
require 'scribo/action_controller_helpers'
require 'scribo/active_record_helpers'
require 'scribo/action_view_helpers'
require 'scribo/version'

module Scribo
  # Configuration
  # What should be the base controller for the admin-side
  mattr_accessor :base_controller

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
