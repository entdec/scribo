# frozen_string_literal: true

namespace :scribo do
  desc 'Release a new version'
  task :release do
    version_file = './lib/scribo/version.rb'
    File.open(version_file, 'w') do |file|
      file.puts <<~EOVERSION
        # frozen_string_literal: true

        module Scribo
          VERSION = '#{Scribo::VERSION.split('.').map(&:to_i).tap { |parts| parts[2] += 1 }.join('.')}'
        end
      EOVERSION
    end
    module Scribo
      remove_const :VERSION
    end
    load version_file
    puts "Updated version to #{Scribo::VERSION}"

    `git commit lib/scribo/version.rb -m "Version #{Scribo::VERSION}"`
    `git push`
    `git tag #{Scribo::VERSION}`
    `git push --tags`
  end
end
