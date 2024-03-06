# frozen_string_literal: true

require 'scribo/preamble'

namespace :scribo do
  desc 'Download jekyllthemes.org theme for testing'
  task :download_jekyllthemes do
    `git clone git@github.com:mattvh/jekyllthemes.git`
    `mkdir -p test/files/themes`

    Dir.glob('jekyllthemes/_posts/**').each do |post|
      data = File.read(post)
      preamble = Scribo::Preamble.parse(data)
      download_url = preamble.metadata['download']
      title = preamble.metadata['title'].downcase.tr(' *', '__')

      next unless download_url.ends_with?('.zip')

      begin
        file = Down.download(download_url, destination: "test/files/themes/#{title}.zip")
      rescue OpenURI::HTTPError
      rescue Down::NotFound
      end
    end

    `rm -rf jekyllthemes`
  end

  namespace :tailwindcss do
    desc "Configure your Tailwind CSS"
    task :config do
      Rails::Generators.invoke("scribo:tailwind_config", ["--force"])
    end
  end

end

if Rake::Task.task_defined?("tailwindcss:build")
  Rake::Task["tailwindcss:build"].enhance(["scribo:tailwindcss:config"])
  Rake::Task["tailwindcss:watch"].enhance(["scribo:tailwindcss:config"])
end
