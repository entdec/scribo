require "compress/zip"
require "admiral"

class Scribo < Admiral::Command
  define_help description: "Scribo command line utility"

  class Publish < Admiral::Command
    def run
      file_name = "#{File.basename(Dir.current)}.zip"
      if !File.exists?("_config.yml")
        puts "No _config.yml found, are you in the correct folder?"
        exit
      end

      File.open(file_name, "w") do |file|
        Compress::Zip::Writer.open(file) do |zip|

          Dir.glob("**/*").each do |file_name|
            next if File.directory?(file_name)
            zip.add file_name, File.open(file_name)
          end
        end
      end
    end
  end

  register_sub_command publish : Publish, description: "Publishes the current site"

  def run
    puts help
  end
end

Scribo.run
