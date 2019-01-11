# frozen_string_literal: true

module Scribo
  module ActionControllerHelpers
    extend ActiveSupport::Concern

    included do
      attr_accessor :scribo_value_purpose, :scribo_value_layout, :scribo_value_application_assets

      if respond_to? :helper_method
        helper_method :scribo_layout_identifier, :scribo_application_assets, :scribo_purpose
      end

      before_action :prepopulate_translations
      after_action :save_translations

      def scribo_layout_identifier
        scribo_value_for(scribo_value_layout)
      end

      def scribo_purpose
        scribo_value_for(scribo_value_purpose)
      end

      def scribo_application_assets
        scribo_value_for(scribo_value_application_assets)
      end

      private

      def scribo_value_for(value)
        return instance_eval(&value) if value.is_a? Proc
        return send(value) if value.is_a? Symbol
        value
      end

      def prepopulate_translations
        return unless defined?(Vario)

        Vario.config.translation_settable&.settings_prepopulate_cache
      end

      # Translations generated in ROLLBACKed transactions should also be saved
      def save_translations
        return unless defined?(Vario)

        Vario.config.translation_settable&.settings_save_unsaved
      end
    end

    class_methods do
      def scribo(*args)
        options = args.extract_options!

        if options.present?
          prepend_before_action do |controller|
            controller.send(:scribo_value_layout=, options[:layout]) if options[:layout]
            controller.send(:scribo_value_purpose=, options[:purpose]) if options[:purpose]
            controller.send(:scribo_value_application_assets=, options[:assets])
          end

          layout 'scribo' if options[:layout]
        end
      end
    end
  end
end
