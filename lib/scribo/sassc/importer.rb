# frozen_string_literal: true

module Scribo
  module SassC
    class Importer < ::SassC::Importer
      def imports(path, parent_path)
        content = options[:content]

        import_path = File.expand_path(path, File.dirname(parent_path))
        # import_path += '/' unless import_path.end_with?('/')
        import_path = '/' + import_path unless import_path.start_with?('/')
        import_path += File.extname(content.path)

        include_content = content.site.contents.located(import_path, restricted: false)
        unless include_content.present?
          # Look for /_file.ext alternative
          import_path = File.dirname(import_path) + '/_' + File.basename(import_path)
          include_content = content.site.contents.located(import_path, restricted: false)
        end

        if include_content.empty? && content.site.properties.value_at_keypath('sass.sass_dir')
          alternate_path = content.site.properties.value_at_keypath('sass.sass_dir')
          # alternate_path += '/' unless alternate_path.end_with?('/')
          alternate_path = '/' + alternate_path unless alternate_path.start_with?('/')

          import_path = File.expand_path(path, alternate_path)
          import_path += File.extname(content.path)

          include_content = content.site.contents.located(import_path, restricted: false)

          unless include_content.present?
            # Look for /_file.ext alternative
            import_path = File.dirname(import_path) + '/_' + File.basename(import_path)
            include_content = content.site.contents.located(import_path, restricted: false)
          end

        end

        puts "No import found: #{import_path}" unless include_content.first
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
      options[:full_path]
    end
  end
end
