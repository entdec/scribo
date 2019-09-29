class RefactorSitesAndContents < ActiveRecord::Migration[5.2]
  def change
    remove_column :scribo_sites, :translations, :string
    remove_column :scribo_contents, :translations, :string

    if Scribo::Content.columns.map(&:name).include?('identifier')
      Scribo::Content.where("identifier IS NOT NULL AND identifier != ''").each do|c|
        next if c.path.present?

        c.path = File.dirname(c.identifier).gsub(/^\./, '') + '/_' + File.basename(c.identifier)
        c.save!
      end
    end

    remove_column :scribo_contents, :identifier, :string
    remove_column :scribo_contents, :name, :string
  end
end
