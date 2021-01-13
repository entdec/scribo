# frozen_string_literal: true

require_dependency 'scribo/application_record'

module Scribo
  # Represents any content in the system
  class Content < ApplicationRecord
    acts_as_nested_set scope: :scribo_site, counter_cache: :children_count

    belongs_to :site, class_name: 'Site', foreign_key: 'scribo_site_id'
    has_one_attached :asset

    validate :post_path
    validate :layout_cant_be_current_content

    before_save :store_properties, if: :config?
    before_save :upload_asset

    after_save :store_full_path
    after_update :store_full_path
    after_move :store_full_path

    scope :layouts, -> { in_folder('_layouts') }
    scope :posts, -> { in_folder('_posts') }
    scope :pages, -> { not_in_folder('_posts').restricted.where(kind: 'text') }
    scope :assets, -> { where(kind: 'asset') }
    scope :html_pages, -> { where("full_path LIKE '%.html' OR full_path LIKE '%.md' OR full_path LIKE '%.markdown'") }
    # html files should be non-filtered html files
    scope :html_files, -> { where("full_path LIKE '%.html'") }
    scope :include, ->(name) { published.where(full_path: ["/_includes/#{name}"]) }
    scope :layout, lambda { |name|
                     published.where(full_path: %W[/_layouts/#{name}.html /_layouts/#{name}.md /_layouts/#{name}.xml /_layouts/#{name}.css])
                   }
    scope :data, lambda { |name|
                   published.where(full_path: %W[/_data/#{name}.yml /_data/#{name}.yaml /_data/#{name}.json /_data/#{name}.csv /_data/#{name}])
                 }

    scope :locale, ->(name) { published.where(full_path: "/_locales/#{name}.yml") }
    scope :locales, -> { published.in_folder('_locales') }

    scope :published, lambda {
                        where("properties->>'published' = 'true' OR properties->>'published' IS NULL").where("properties->>'published_at' IS NULL OR properties->>'published_at' <= :now", now: Time.current.utc)
                      }
    scope :restricted, -> { where("full_path NOT LIKE '/\\_%'") }

    scope :not_in_folder, lambda { |folder_name|
                            where('id NOT IN (?)', Scribo::Content.where(kind: 'folder').find_by(path: folder_name)&.descendants&.pluck(:id) || [])
                          }
    scope :in_folder, lambda { |folder_name|
                        where(id: Scribo::Content.where(kind: 'folder').find_by(path: folder_name)&.descendants&.pluck(:id) || [])
                      }

    scope :permalinked, ->(paths) { where("properties->>'permalink' IN (?)", paths) }

    def self.located(path, restricted: true)
      restricted = true if restricted.nil? # If blank it's still restricted

      result = published.where(full_path: search_paths_for(path))
      result = result.restricted if restricted
      result.or(published.permalinked(search_paths_for(path)))
    end

    # Uses https://www.postgresql.org/docs/current/textsearch-controls.html
    def self.search(search_string)
      where(
        "to_tsvector(scribo_contents.data || ' ' || COALESCE(scribo_contents.properties::text, '')) @@ to_tsquery(?)", search_string
      )
    end

    # Name of the currently in use layout
    def layout_name
      properties&.key?('layout') ? properties&.[]('layout') : ''
    end

    # Layout as content
    def layout
      return nil unless layout_name.present?

      site.contents.layout(layout_name).first
    end

    def identifier
      File.basename(path, File.extname(path))
    end

    # Data with frontmatter, used for maintenance and import/export
    def data_with_frontmatter
      return asset.attachment&.download || data if kind != 'text'

      result = ''
      # Use attributes['properties'] here, to always use content-local properties
      result += (YAML.dump(attributes['properties']) + "---\n") if attributes['properties'].present?

      result + data.to_s
    end

    # Data with frontmatter setter
    def data_with_frontmatter=(text)
      if kind == 'text'
        data_with_metadata = Scribo::Preamble.parse(text)
        self.properties = data_with_metadata.metadata
        self.data = data_with_metadata.content
      else
        self.data = text
      end
    end

    # Used for merging with defaults
    def properties
      attributes['properties']
      # defaults.merge(attributes['properties'] || {})
    end

    def properties=(text)
      props = text.is_a?(String) ? Scribo::Utility.yaml_safe_parse(text) : text
      write_attribute :properties, props
    end

    def type
      collection_name
    end

    def permalink
      properties&.[]('permalink')
    end

    def url
      result = permalink || Scribo::Utility.switch_extension(full_path)
      result += '/' unless result.end_with?('/')
      result
    end

    def date
      return nil unless post?

      prop_date = begin
        Time.zone.parse(properties['date'])
      rescue StandardError
        nil
      end

      prop_date || post_date
    end

    def post_date
      Time.zone.strptime(path[0, 10], '%Y-%m-%d')
    rescue StandardError
      nil
    end

    def data
      return attributes['data'] if kind == 'asset'

      attributes['data']&.force_encoding('utf-8')
    end

    def excerpt
      # FIXME: This is a terrible implementation
      excerpt_part = data.gsub("\r\n", "\n\n").split("\n\n").reject(&:empty?).reject { |p| p.start_with?('#') }.first
      Scribo::ContentRenderService.new(self, {}, data: excerpt_part, layout: false).call
    end

    def categories
      if properties&.[]('categories').is_a? Array
        properties&.[]('categories')
      else
        (properties&.[]('categories') || '').split
      end
    end

    def tags
      if properties&.[]('tags').is_a? Array
        properties&.[]('tags')
      else
        (properties&.[]('tags') || '').split
      end
    end

    def content_type
      properties&.[]('content_type') || mime_type&.content_type || 'application/octet-stream'
    end

    def media_type
      mime_type&.media_type
    end

    def extension
      mime_type&.extensions&.first
    end

    def mime_type
      MIME::Types.type_for(path).first
    end

    def dir
      File.dirname(full_path)
    end

    def extname
      File.extname(full_path).tr('.', '')
    end

    def translation_scope
      scope = File.dirname(full_path).split('/')
      scope << File.basename(full_path, File.extname(full_path))
      scope.join('.')
    end

    def cache_key
      "#{super}-#{updated_at}-#{I18n.locale}"
    end

    def collection_name
      return nil unless part_of_collection?

      ancestors.first.path[1..-1]
    end

    def part_of_collection?
      return false unless ancestors.first&.path&.start_with?('_')

      site.collections.include?(ancestors.first.path[1..-1])
    end

    def redirect?
      extname == 'link'
    end

    def layout?
      full_path.start_with?('/_layouts/')
    end

    def post?
      ancestors.map(&:path).join('/').start_with?('_posts')
    end

    def page?
      Scribo::Utility.output_content_type(self) == 'text/html'
    end

    def config?
      full_path == '/_config.yml'
    end

    def asset?
      kind == 'asset'
    end

    def folder?
      kind == 'folder'
    end

    def self.paginated?(path)
      path.match(%r[/(\d+)/$])
    end

    def self.search_paths_for(path)
      search_paths = []

      search_path = path
      search_path = "/#{search_path}" unless search_path.start_with?('/')
      search_path.gsub!(%r[/\d+/$], '/') if paginated?(search_path)
      search_path = "#{search_path}index.html" if search_path.ends_with?('/')

      search_paths.concat(alternative_paths_for(search_path))

      secondary_search_path = path.sub(%r[/$], '')
      secondary_search_path = "/#{secondary_search_path}" unless secondary_search_path.start_with?('/')
      search_paths.concat(alternative_paths_for(secondary_search_path)) if secondary_search_path != '' && secondary_search_path != search_path

      permalink_paths = [path]

      normalized_path = path
      normalized_path = "/#{normalized_path}" unless normalized_path.start_with?('/')
      normalized_path = "#{normalized_path}/" unless normalized_path.ends_with?('/')
      permalink_paths << normalized_path
      search_paths.concat(permalink_paths) # deal with permalinks

      search_paths.uniq
    end

    def self.alternative_paths_for(search_path)
      search_paths = []
      search_path = Scribo::Utility.switch_extension(search_path, 'html') unless File.extname(search_path).present?
      search_paths.concat(Scribo::Utility.variations_for_path(search_path))
      search_paths << Scribo::Utility.switch_extension(search_path, 'link')
    end

    def store_full_path(force = false)
      # TODO: Check why saved_changes is empty at times
      if force || saved_changes.include?(:path) || saved_changes.empty?

        if post?
          result = categories.join('/') + '/'
          result += date.strftime('%Y/%m/%d/') if date
          result += path[11..-1]
        elsif part_of_collection? && site.output_collection?(collection_name)
          result = "#{collection_name}/#{path}"
        else
          result = (ancestors.map(&:path) << path).join('/')
        end
        result = '/' + result unless result.start_with?('/')

        update_column(:full_path, result)

        children.reload.each do |child|
          child.store_full_path(true)
        end

      end
    end

    def tree_path
      result = (ancestors.map(&:path) << path).join('/')
      result = '/' + result unless result.start_with?('/')
      result
    end

    private

    def upload_asset
      return unless asset?
      # return unless data.present? -> Breaks with utf8?
      return unless data
      return unless data.size.positive?

      si = StringIO.new
      si.write(data)
      si.rewind

      asset.attach(io: si, filename: path, content_type: content_type)

      self.data = nil
    end

    def store_properties
      return unless attributes['data'].present?

      new_properties = Scribo::Utility.yaml_safe_parse(attributes['data'])
      old_properties = site.properties
      site.update(properties: new_properties)

      # Only reshuffle if they need to
      if old_properties['collections'] != new_properties['collections'] ||
         old_properties['permalink'] != new_properties['permalink']
        site.reshuffle!
      end
    end

    def post_path
      return unless post?

      errors.add(:path, 'path must be of format YYYY-MM-DD-title') unless path.match(/[0-9]{4}-[0-9]{1,2}-[0-9]{1,2}-.*/)
    end

    def layout_cant_be_current_content
      return unless layout

      errors.add(:base, "layout can't be layout of itself") if layout.full_path == full_path
    end

    class << self
      def redirect_options(redirect_data)
        options = redirect_data.split
        if options.length == 2
          options[0] = options[0].to_i
        else
          options.unshift 302
        end
        options
      end
    end
  end
end
