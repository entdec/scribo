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
        total_data = content.data
        current_layout = content.layout
        loop do
          Rails.logger.error "Scribo rendering #{content.path}, layout: #{current_layout}, registers: #{registers.keys}"
          total_data = Liquor.render(total_data, assigns: assigns, registers: registers, filter: filter, layout: current_layout&.data)
          current_layout = current_layout&.layout
          break unless current_layout
        end
        total_data
      end
    end

    private

    def render_asset
      return unless content.kind == 'asset'
      return content.data if content.data.present?
      return unless content.asset.attached?

      content.asset.download
    end

    def filter
      if Scribo::Content.columns.map(&:name).include?('filter') && content.filter
        content.filter
      elsif content.path
        Scribo::Utility.filter_for_path(content.path)
      end
    end

    def assigns
      assigns = { 'content' => content, 'site' => content.site }
      assigns['request'] = ActionDispatch::RequestDrop.new(context.request) if context.respond_to?(:request)

      context.instance_variables.reject { |i| i.to_s.starts_with?('@_') }.each do |i|
        assigns[i.to_s[1..-1]] = context.instance_variable_get(i)
      end
      assigns
    end

    def registers
      hash = { 'controller' => context, 'content' => content }
      hash.merge!(options[:registers]) if options[:registers]
      hash.stringify_keys
    end
  end
end
