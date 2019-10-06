# frozen_string_literal: true

class ContentAndSiteAttributesToProperties < ActiveRecord::Migration[5.2]
  def change
    Scribo::Site.all.each do |site|
      site.properties = {} unless site.properties

      set_property(site, :title, site.name)
      site.save!
    end

    Scribo::Content.all.each do |content|
      content.properties = {} unless content.properties

      set_property(content, :layout, content.layout&.path)
      set_property(content, :filter, content.filter)
      set_property(content, :title, content.title)
      set_property(content, :caption, content.caption)
      set_property(content, :keywords, content.keywords)
      set_property(content, :description, content.description)

      content.save!
    end

    remove_column :scribo_sites, :name, :string

    remove_column :scribo_contents, :content_type, :string
    remove_column :scribo_contents, :filter, :string
    remove_column :scribo_contents, :title, :string
    remove_column :scribo_contents, :caption, :string
    remove_column :scribo_contents, :breadcrumb, :string
    remove_column :scribo_contents, :keywords, :string
    remove_column :scribo_contents, :description, :string

    remove_reference :scribo_contents, :layout, index: true, foreign_key: { to_table: 'scribo_contents', column: 'layout_id' }, type: :uuid
  end

  private

  def set_property(obj, property, value)
    obj.properties.delete(property.to_s) if obj.properties[property.to_s].blank?
    return unless value

    obj.properties[property.to_s] = value unless obj.properties[property.to_s]
  end
end
