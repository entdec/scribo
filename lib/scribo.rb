# frozen_string_literal: true

require 'awesome_nested_set'
require 'down'
require 'kaminari'
require 'liquid'
require 'liquor'
require 'mime/types'
require 'rouge'
require 'simple_form'
require 'slim-rails'
require 'zip'

require 'scribo/action_controller_helpers'
require 'scribo/active_record_helpers'
require 'scribo/action_view_helpers'
require 'scribo/action_controller_renderers'
require 'scribo/configuration'
require 'scribo/engine'
require 'scribo/i18n_store'
require 'scribo/liquid/parser'
require 'scribo/preamble'
require 'scribo/sassc/importer'
require 'scribo/utility'
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

    def i18n_store
      @i18n_store ||= Scribo::I18nStore.new
    end

    def logger
      @config.logger
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
