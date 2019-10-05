# frozen_string_literal: true

require_dependency 'scribo/application_service'

module Scribo
  class ContentRenderService < ApplicationService
    attr_reader :content, :context, :options

    def initialize(content, context, options = {})
      @content = content
      @context = context
      @options = options
    end

    def perform
      case content.kind
      when 'asset'
        render_asset
      when 'text', 'redirect'
        content_data = content.data
        current_layout = content.layout
        loop do
          puts "Scribo rendering #{content.path}, layout: #{current_layout}, registers: #{registers.keys}"
          content_data = render_liquor(content_data, current_layout&.data)
          current_layout = current_layout&.layout
          break unless current_layout
        end
        content_data
      end
    end

    private

    def render_liquor(content_data, layout_data)
      # content_data = render_liquor(content_data, layout_data)
      Liquor.render(content_data, assigns: assigns, registers: registers, filter: filter, filter_options: filter_options, layout: layout_data)
    end

    def render_asset
      return unless content.kind == 'asset'
      return content.data if content.data.present?
      return unless content.asset.attached?

      content.asset.download
    end

    def filter
      return options[:filter] if options.key?(:filter)

      if Scribo::Content.columns.map(&:name).include?('filter') && content.filter
        content.filter
      elsif content.path
        Scribo::Utility.filter_for_path(content.path)
      end
    end

    def filter_options
      @filter_options = { full_path: content.full_path, content: content }
      @filter_options[:importer] = Scribo::SassC::Importer if %w[sass scss].include?(filter)
      @filter_options
    end

    def assigns
      return @assigns if @assigns

      @assigns = { 'content' => content, 'site' => content.site }
      @assigns.merge!(options[:assigns]) if options[:assigns]
      @assigns['request'] = ActionDispatch::RequestDrop.new(context.request) if context.respond_to?(:request)

      context.instance_variables.reject { |i| i.to_s.starts_with?('@_') }.each do |i|
        @assigns[i.to_s[1..-1]] = context.instance_variable_get(i)
      end
      @assigns = @assigns.stringify_keys
      @assigns
    end

    def registers
      return @registers if @registers

      @registers = { 'controller' => context, 'content' => content }
      @registers.merge!(options[:registers]) if options[:registers]
      @registers = @registers.stringify_keys
      @registers
    end
  end
end
