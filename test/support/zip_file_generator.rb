class ZipFileGenerator
  attr_reader :path, :folder_entries, :base_name

  def initialize(path, folder_entries: true, containing_folder: false)
    @path = path
    @folder_entries = folder_entries
    @base_name = if containing_folder
                   path.split('/').last + '/'
                 else
                   ''
                 end
  end

  def write
    file = Tempfile.new(['hello', '.jpg'])
    Zip::File.open(file.path, 'w') do |zipfile|
      Dir["#{path}/**/**"].each do |file|
        next if File.directory?(file) && folder_entries == false

        zipfile.add(base_name + file.sub(path + '/', ''), file)
      end
    end
    file
  end
end
