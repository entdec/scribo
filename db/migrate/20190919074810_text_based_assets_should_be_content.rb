class TextBasedAssetsShouldBeContent < ActiveRecord::Migration[5.2]
  def change
    Scribo::Content.where(content_type: Scribo.config.supported_mime_types[:text]+Scribo.config.supported_mime_types[:script]+Scribo.config.supported_mime_types[:style]).update(kind: 'text')
  end
end