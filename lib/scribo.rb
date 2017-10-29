# frozen_string_literal: true

require 'scribo/engine'
require 'scribo/active_record_helpers'
require 'scribo/action_view_helpers'

module Scribo
  # Your code goes here...

  # Include helpers
  ActiveSupport.on_load(:active_record) do
    include ActiveRecordHelpers
  end
  ActiveSupport.on_load(:action_view) do
    include ActionViewHelpers
  end
end
