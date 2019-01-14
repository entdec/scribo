# frozen_string_literal: true

require 'liquid'
require 'liquid/tag/parser'
require 'acts_as_tree'
require 'state_machines-activerecord'
require 'simple_form'
require 'zip'

require 'scribo/engine'
require 'scribo/configuration'
require 'scribo/action_controller_helpers'
require 'scribo/active_record_helpers'
require 'scribo/action_view_helpers'
require 'scribo/version'

module Scribo
  # Configuration
  class Error < StandardError; end

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
