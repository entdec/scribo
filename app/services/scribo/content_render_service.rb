# frozen_string_literal: true

require_dependency 'scribo/application_service'

module Scribo
  class ContentRenderService < ApplicationService
    attr_reader :content, :context, :options

    def initialize(content, context, options = {})
      super()
      @content = content
      @context = context
      @options = options
      @assigns = nil
      @registers = nil
    end

    def perform
      if content.kind == 'asset'
        render_asset
      else
        layout = options[:layout] == false ? nil : content.layout

        # FIXME: Though this works for layout, we need to be able to merge all properties with defaults
        # Luckily this is mostly used for layouts
        if options[:site]
          layout_name = options[:site].defaults_for(content)['layout']
          layout ||= options[:site].contents.layout(layout_name).first if layout_name
        end

        render_liquor(options[:data] || content.data, layout)
      end
    end

    private

    def render_liquor(data, layout)
      result = Liquor.render(data, assigns: assigns.merge!('content' => data), registers: registers, filter: filter,
                                   filter_options: filter_options, layout: layout&.data)

      while layout&.layout
        next unless layout&.layout

        layout = layout.layout
        result = Liquor.render(layout.data, assigns: assigns.merge('content' => result), registers: registers)
      end

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

      if content.properties&.key?('filter')
        content.properties['filter']
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

      @assigns = {}
      @assigns.merge!(options[:assigns]) if options[:assigns]

      context.instance_variables.reject { |i| i.to_s.starts_with?('@_') }.each do |i|
        @assigns[i.to_s[1..-1]] = context.instance_variable_get(i)
      end

      @assigns['request'] = Scribo::ActionDispatch::RequestDrop.new(context.request) if context.respond_to?(:request)
      @assigns['site'] = options[:site] || content.site
      @assigns['page'] = content
      @assigns['paginator'] = Scribo::PaginatorDrop.new(@assigns['site'], content)

      @assigns = @assigns.stringify_keys
      @assigns
    end

    def registers
      return @registers if @registers

      @registers = { 'controller' => context, 'content' => content, 'site' => content.site }
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
