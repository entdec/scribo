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
        render_liquor(options[:data] || content.data, options[:layout] == false ? nil : content.layout)
      end
    end

    private

    def render_liquor(data, layout)
      result = Liquor.render(data, assigns: assigns.merge!('content' => data), registers: registers, filter: filter, filter_options: filter_options, layout: layout&.data)
      result = render_liquor(result, layout.layout) if layout&.layout
      result
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
      @filter_options.merge!(markdown_filter_options) if %w[markdown].include?(filter)
      @filter_options
    end

    def assigns
      return @assigns if @assigns

      @assigns = { 'site' => content.site, 'page' => content }
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

    def markdown_filter_options
      {
        auto_ids: true,
        toc_levels: '1..6',
        entity_output: 'as_char',
        smart_quotes: 'lsquo,rsquo,ldquo,rdquo',
        input: 'GFM',
        hard_wrap: false,
        guess_lang: true,
        footnote_nr: 1,
        show_warnings: false,
        syntax_highlighter: 'rouge'

        # syntax_highlighter_opts: {
        #   bold_every: 8,
        #   css: :class,
        #   css_class: 'highlight',
        #   formatter: ::Rouge::Formatters::HTMLLegacy,
        #   foobar: 'lipsum'
        # }
      }
    end
  end
end
