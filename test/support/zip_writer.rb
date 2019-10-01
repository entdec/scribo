class ZipFileGenerator
  # Initialize with the directory to zip and the location of the output archive.
  def initialize(input_dir, options = {})
    @input_dir = input_dir
    @base_path = File.basename(input_dir) + '/'
    @options = options
  end

  # Zip the input directory.
  def write(f)
    entries = Dir.entries(@input_dir) - %w[. ..]

    buffer = Zip::OutputStream.write_buffer do |zipfile|
      write_entries entries, '', zipfile
    end
    f.write(buffer.string)
    f.flush
  end

  private

  # A helper method to make the recursion work.
  def write_entries(entries, path, zipfile)
    entries.each do |e|
      zipfile_path = path == '' ? e : File.join(path, e)
      disk_file_path = File.join(@input_dir, zipfile_path)

      if File.directory? disk_file_path
        recursively_deflate_directory(disk_file_path, zipfile, zipfile_path)
      else
        put_into_archive(disk_file_path, zipfile, zipfile_path)
      end
    end
  end

  def recursively_deflate_directory(disk_file_path, zipfile, zipfile_path)
    zipfile.put_next_entry(@base_path + zipfile_path) unless @options[:folder_entries] == false
    subdir = Dir.entries(disk_file_path) - %w[. ..]
    write_entries subdir, zipfile_path, zipfile
  end

  def put_into_archive(disk_file_path, zipfile, zipfile_path)
    zipfile.put_next_entry(@base_path + zipfile_path)
    zipfile.write File.read(disk_file_path)
  end
end
