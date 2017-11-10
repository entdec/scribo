module Scribo
  module ActionControllerHelpers
    extend ActiveSupport::Concern

    included do
      attr_accessor :scribo_value_site, :scribo_value_layout

      if respond_to? :helper_method
        helper_method :scribo_layout_identifier, :scribo_current_site
      end

      def scribo_determines_the_layout
        'scribo'
      end

      def scribo_current_site
        scribo_value_for(scribo_value_site)
      end

      def scribo_layout_identifier
        scribo_value_for(scribo_value_layout)
      end

      private

      def scribo_value_for(value)
        return instance_eval(&value) if value.is_a? Proc
        return send(value) if value.is_a? Symbol
        value
      end
    end

    class_methods do
      def scribo_layout(scribo_value_layout)
        before_action do |controller|
          controller.send(:scribo_value_layout=, scribo_value_layout)
        end

        layout :scribo_determines_the_layout
      end

      def scribo_site(scribo_value_site)
        before_action do |controller|
          controller.send(:scribo_value_site=, scribo_value_site)
        end
      end
    end
  end
end
