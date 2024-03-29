# frozen_string_literal: true

module Scribo
  module SassC
    class Importer < ::SassC::Importer
      def imports(path, parent_path)
        content = options[:content]

        import_path = ''
        if path.start_with?('/')
          import_path += path
        else
          import_path += content.site.sass_dir
          import_path += '/' unless import_path.end_with?('/')

          import_path += path
          import_path += File.extname(content.path)
          import_path = File.expand_path(import_path, content.site.sass_dir)
          unless import_path.start_with?(content.site.sass_dir)
            # import_path always starts with /
            import_path = content.site.sass_dir + import_path[1..-1]
          end
        end

        include_content = content.site.contents.where(kind: 'text').located(import_path, restricted: false)
        unless include_content.present?
          # Look for /_file.ext alternative
          import_path = File.dirname(import_path) + '/_' + File.basename(import_path)
          include_content = content.site.contents.where(kind: 'text').located(import_path, restricted: false)
        end

        # Look in parent's folder
        if include_content.blank? && File.dirname(parent_path) != '.'
          import_path = content.site.sass_dir + File.dirname(parent_path) + '/' + File.basename(import_path)
          include_content = content.site.contents.where(kind: 'text').located(import_path, restricted: false)
        end

        if include_content.empty? && content.site.properties.value_at_keypath('sass.sass_dir')
          alternate_path = content.site.properties.value_at_keypath('sass.sass_dir')
          # alternate_path += '/' unless alternate_path.end_with?('/')
          alternate_path = '/' + alternate_path unless alternate_path.start_with?('/')

          import_path = File.expand_path(path, alternate_path)
          import_path += File.extname(content.path)

          include_content = content.site.contents.where(kind: 'text').located(import_path, restricted: false)

          unless include_content.present?
            # Look for /_file.ext alternative
            import_path = File.dirname(import_path) + '/_' + File.basename(import_path)
            include_content = content.site.contents.located(import_path, restricted: false)
          end

        end

        Scribo.config.logger.warn "SassC::Importer: No import found: #{import_path}" unless include_content.first
        # FIXME: Add context
        # Here we don't use a filter
        source = ContentRenderService.new(include_content.first, {}, filter: nil).call || ''
        ::SassC::Importer::Import.new(path, source: source)
      end
    end
  end
end

module Tilt
  class Template
    def eval_file
      options[:full_path] || file || '(__TEMPLATE__)'
    end
  end
end
