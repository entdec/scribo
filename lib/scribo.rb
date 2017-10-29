# frozen_string_literal: true

require 'scribo/engine'
require 'scribo/active_record_helpers'

module Scribo
  # Your code goes here...

  # Include helpers
  ActiveSupport.on_load(:active_record) do
    include ActiveRecordHelpers
  end
end
