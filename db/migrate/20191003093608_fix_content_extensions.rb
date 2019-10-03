# frozen_string_literal: true

class FixContentExtensions < ActiveRecord::Migration[5.2]
  def change
    Scribo::Content.where(kind: 'text').each do |content|
      puts content.full_path
      next unless File.extname(content.path).empty?

      new_path = if content.path == '/'
                   'index.html'
                 else
                   ext = MIME::Types[content.content_type].first.preferred_extension
                   "#{content.path}.#{ext}"
                 end
      content.update(path: new_path)
    end

    Scribo::Content.where(kind: 'redirect').each do |content|
      next if File.extname(content.path) == '.link'

      new_path = File.basename(content.path) + '.link'
      content.update(path: new_path)
    end
  end
end
