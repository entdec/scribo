# frozen_string_literal: true

class ChangeRedirectsIntoText < ActiveRecord::Migration[5.2]
  def change
    Scribo::Content.where(kind: 'redirect').each do |content|
      new_path = if File.extname(content.path) == '.link'
                   content.path
                 else
                   File.basename(content.path) + '.link'
                 end
      content.update(path: new_path, kind: 'text')
    end
  end
end
