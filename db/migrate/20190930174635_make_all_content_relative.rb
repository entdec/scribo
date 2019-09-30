class MakeAllContentRelative < ActiveRecord::Migration[5.2]
  def change
    Scribo::Site.all.each do |s|
      s.contents.rebuild!
      s.contents.each do |c|
        if c.path&.index('/')
          puts c.path
          parts = c.path.split('/').reject(&:empty?)

          if parts.size > 0
            new_parent = nil
            parts[0..-2].each_with_index do |p, index|
              puts "parent: #{new_parent}, path: #{p}, kind: 'folder', depth: #{index}"
              new_parent = s.contents.find_or_create_by(parent: new_parent, path: p, kind: 'folder')
              c.parent = new_parent
            end
          end
          c.path = parts[-1].present? ? parts[-1] : '/'
          c.save
        end
        if c.path.nil?
          c.path = c.id
          c.save
        end
      end
    end
  end
end
