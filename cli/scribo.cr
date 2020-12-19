require "compress/zip"
require "admiral"
require "yaml"
require "http/client"

class Scribo
  def initialize
  end

  def zip_and_upload
    if !config["endpoint"]? || config["api_key"]?
      puts "Please configure an endpoint and api_key in your _config.yml:\n\n"
      puts "cli:\n  endpoint: https://example.com/\n  api_key: someapikey"
      exit
    end

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

  def init_example(name)
    if Dir.exists?(name)
      puts "A folder #{name} already exists, move this out of the way first."
      exit
    end

    Dir.mkdir_p("#{name}/assets/images")
    Dir.mkdir_p("#{name}/assets/fonts")
    Dir.mkdir_p("#{name}/assets/style")
    Dir.mkdir_p("#{name}/_layouts")
    File.open("#{name}/_config.yml", "w") do |file|
      file.puts "# General configuration\ntitle: #{name}\nbaseurl: /#{name}\n\n# Scribo command line utility related\n\ncli:\n  endpoint: https://example.com/scribo\n  api_key: someapikey"
    end
    File.open("#{name}/index.md", "w") do |file|
      file.puts "---\nlayout: default\n---\n# Welcome to #{name}\nYou can find the contents of this page in index.md"
    end
    File.open("#{name}/_layouts/default.html", "w") do |file|
      file.puts %(<!DOCTYPE html>\n<html>\n<head>\n  <title></title>\n  <meta name="viewport" content="width=device-width, initial-scale=1">\n<body>\n  {{content}}\n</body>\n</html>)
    end
  end

  # private

  def config
    config = YAML.parse(File.read("_config.yml"))
    config = config["cli"]
  end

  def import_url
    "#{config["endpoint"]}/api/sites/import"
  end
end

class ScriboCommand < Admiral::Command
  define_help description: "Scribo command line utility"

  class PublishCommand < Admiral::Command
    def run
      Scribo.new.zip_and_upload
    end
  end

  class InitCommand < Admiral::Command
    define_help description: "Initializes a new site"
    define_argument name, required: true

    def run
      Scribo.new.init_example(arguments.name)
    end
  end

  register_sub_command publish : PublishCommand, description: "Uploads the current site"
  register_sub_command init : InitCommand, description: "Creates a new site"

  def run
    puts help

    if !File.exists?("_config.yml")
      puts "\nNo _config.yml found, are you in the correct folder?"
      exit
    end
  end
end

ScriboCommand.run
