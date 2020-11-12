require "compress/zip"
require "admiral"
require "yaml"
require "http/client"

class Scribo
  def initialize
  end

  def zip_and_upload
    zip_file_name = "#{File.basename(Dir.current)}.zip"
    tempfile = File.tempfile(zip_file_name)
    File.open(tempfile.path, "w") do |file|
      Compress::Zip::Writer.open(file) do |zip|

        Dir.glob("**/*").each do |file_name|
          next if File.directory?(file_name)
          zip.add file_name, File.open(file_name)
        end
      end
    end

    io = IO::Memory.new
    builder = HTTP::FormData::Builder.new(io, "aA47")
    builder.file("files[]", File.open(tempfile.path), HTTP::FormData::FileMetadata.new(filename: zip_file_name))
    builder.finish

    response = HTTP::Client.post(import_url, headers: HTTP::Headers{"User-Agent" => "Scribo"}, body: io.to_s)

    tempfile.delete
  end

  def config
    config = YAML.parse(File.read("_config.yml"))
    config = config["cli"]
  end

  def import_url
    "#{config["endpoint"]}/import"
  end
end

class ScriboCommand < Admiral::Command
  define_help description: "Scribo command line utility"

  class PublishCommand < Admiral::Command
    def run
      Scribo.new.zip_and_upload
    end
  end

  register_sub_command publish : PublishCommand, description: "Publishes the current site"

  def run
    puts help

    if !File.exists?("_config.yml")
      puts "\nNo _config.yml found, are you in the correct folder?"
      exit
    end
  end
end

ScriboCommand.run
