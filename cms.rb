# frozen_string_literal: true

BINARIES = %w[png jpg mp4].freeze

channel = ENV['CHANNEL']
what    = ENV['WHAT']

channel = Channel.find_by(name: channel)
site = channel.sites.first || channel.sites.create

if what == 'export'

  Content.where(channel: Channel.find_by(name: channel)).where.not(path: [nil, '']).each do |c|
    path       = c.path
    path       = '/index' if c.path == '/'
    total_path = "cms/#{channel}#{path}"
    puts "total_path: #{total_path}"
    base_name = File.basename(total_path)

    puts "base_name: #{base_name} - #{-(base_name.length + 2)}"
    only_path = total_path[0..-(base_name.length + 2)]
    puts "only_path: #{only_path}"
    FileUtils.mkdir_p(only_path) if only_path.present? && !File.exist?(only_path)
    File.open("cms/#{channel}#{path}", 'wb') { |file| file.write(c.data) }
  end

  Scribo::Content.where(channel: Channel.find_by(name: channel)).where.not(identifier: nil).each do |c|
    FileUtils.mkdir_p("cms/#{channel}/_identified") unless File.exist?("cms/#{channel}/_identified")
    File.open("cms/#{channel}/_identified/#{c.name.tr('/', '_')}", 'wb') { |file| file.write(c.data) }
  end

elsif what == 'import'
  Dir.glob("cms/#{channel.name}/**/*").reject { |p| p["cms/#{channel.name}/".length] == '_' }.reject { |path| File.directory?(path) }.each do |path|
    mime_type = `file --brief --mime-type "#{path}"`.strip
    mime_type ||= 'text/html'
    import_path = path["cms/#{channel.name}".length..-1]
    import_path = '/' if import_path == '/index'

    puts mime_type
    c = site.contents.find_or_create_by(site: site, path: import_path)
    c.data = File.read(path, mode: 'rb')
    c.state = 'published'
    c.path = import_path
    c.content_type = mime_type
    c.kind = Scribo::Content::SUPPORTED_MIME_TYPES[:text].include?(mime_type) ? 'content' : 'asset'
    c.save
  end

  Dir.glob("cms/#{channel.name}/_identified/*").reject { |path| File.directory?(path) }.each do |path|
    name = File.basename(path).tr('_', '/')
    mime_type = `file --brief --mime-type "#{path}"`.strip
    mime_type ||= 'text/html'

    puts mime_type

    c = site.contents.find_or_create_by(site: site, identifier: name)
    c.data = File.read(path, mode: 'rb')
    c.state = 'published'
    c.identifier = name
    c.content_type = mime_type
    c.kind = Scribo::Content::SUPPORTED_MIME_TYPES[:text].include?(mime_type) ? 'content' : 'asset'
    c.save
  end
end
