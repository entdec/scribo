module Scribo
  class Configuration
    attr_accessor :admin_authentication_module, :base_controller, :supported_mime_types, :default_404_txt,
                  :default_humans_txt, :default_robots_txt, :default_favicon_ico, :templates
    attr_writer :logger, :scribable_objects, :scribable_for_request, :after_site_create, :admin_mount_point, :default_site

    def initialize
      @logger = Logger.new(STDOUT)
      @logger.level = Logger::INFO
      @base_controller = '::ApplicationController'
      @supported_mime_types = {
        image: %w[image/gif image/png image/jpeg image/bmp image/webp image/svg+xml],
        text: %w[text/plain text/html application/json application/xml],
        style: %w[text/css],
        script: %w[text/javascript application/javascript application/x-javascript],
        audio: %w[audio/midi audio/mpeg audio/webm audio/ogg audio/wav],
        video: %w[video/webm video/ogg video/mp4],
        document: %w[application/msword application/vnd.ms-powerpoint application/vnd.ms-excel application/pdf
                     application/zip],
        font: %w[font/collection font/otf font/sfnt font/ttf font/woff font/woff2 application/font-ttf
                 application/x-font-ttf application/vnd.ms-fontobject application/font-woff],
        other: %w[application/octet-stream]
      }
      @default_404_txt = '404 Not Found'
      @default_humans_txt = <<~HUMANS_TXT
        /* TEAM */
        Your title: Your name.
        Site: email, link to a contact form, etc.
        Twitter: your Twitter username.
        Location: City, Country.

                                [...]

        /* THANKS */
        Name: name or url

                                [...]

        /* SITE */
        Last update: YYYY/MM/DD
        Standards: HTML5, CSS3,..
        Components: Modernizr, jQuery, etc.
        Software: Software used for the development
      HUMANS_TXT
      @default_robots_txt = <<~ROBOTS_TXT
        # See http://www.robotstxt.org/robotstxt.html for documentation on how to use the robots.txt file
        #
        # To ban all spiders from the entire site uncomment the next two lines:
        # User-agent: *
        # Disallow: /
      ROBOTS_TXT

      # Base64 encoded image/x-icon
      @default_favicon_ico = 'AAABAAEAEBAAAAEAIABoBAAAFgAAACgAAAAQAAAAIAAAAAEAIAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAEcrEvoAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAsHIH/7d2Bv+3dgb/t3YG/7d2Bv0AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAt3YG/0crEv+3dgb/t3YG/7d2Bv8AAAAAt3YG/7d2Bv90Vx0DAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAALd2Bv+3dgb/t3YG/7d2Bv+3dgb/t3YG/7d2Bv+3dgb/t3YG/3VLBEwAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAC3dgb/t3YG/0crEv+3dgb/t3YG/7d2Bv+3dgb/t3YG/7d2Bv+3dgb+AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAt3YG/bd2Bv+3dgb/qGwI/7d2Bv+3dgb/t3YG/7d2Bv8AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAC3dgb/t3YG/7d2Bv+3dgb/t3YG/7d2Bv+3dgb/t3YG/7d2Bv+3dgb/AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAt3YG/7d2Bv+3dgb/lV8K/7d2Bv+3dgb/t3YG/7d2Bv+3dgb/t3YG/7h2B9EAAAAAAAAAAAAAAAAAAAAAAAAAALd2Bv+3dgb/t3YG/7d2Bv+JWAv/t3YG/7d2Bv+3dgb/t3YG/7d2Bv+3dgb/AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAt3YG/7d2Bv+3dgb/t3YG/7d2Bv+3dgb/t3YG/7d2Bv+3dgb/t3YG/wAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAALd2Bvi3dgb/t3YG+7d2Bv+3dgb/t3YG/7d2Bv+3dgb/t3YG/wAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAt3YG/wAAAAC3dgb/t3YG/7d2Bv+3dgb/t3YG/7d2Bv+3dgb/t3YG8AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAt3YG/7d2Bv+3dgb/t3YG/7d2Bv+3dgb/t3YG/7d2Bv8AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAC3dgb/t3YG/2hDA3O3dgb/t3YG/7d2Bv+3dgb/t3YG/QAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAC4dgeJAAAAALd2Bv+3dgb/t3YG/7d2Bv+zcgZ3//8AAL//AADB/wAAgn8AAIA/AACAHwAAgH8AAMAPAADABwAAwAcAAOAHAADgDwAA9AMAAPwDAAD+QQAA/6EAAA=='

      # This needs an array of hashes, each hash MUST include an id, thumbnail and a url:
      # [
      #   { id: '7becd952-ae77-43ad-9bf7-ed4f8feb59fa', thumbnail: 'https://mysite.net/template1.png', url: 'https://mysite.net/template1.zip' }
      # ]
      #
      # The id can be generated using: `SecureRandom.uuid`, or you can use integers
      @templates = []

      # Default site if no site is found, this can be nil, an actual site instance or a proc which will resolve a site instance.
      @default_site = nil
    end

    # logger [Object].
    def logger
      @logger.is_a?(Proc) ? instance_exec(&@logger) : @logger
    end

    def default_site(request = nil)
      @default_site.is_a?(Proc) ? instance_exec(request, &@default_site) : @default_site
    end

    # admin_mount_point [String].
    def admin_mount_point
      @admin_mount_point ||= '/'
    end

    # Only used to limit what users can see when using admin
    def scribable_objects
      [*instance_exec(&@scribable_objects)] if @scribable_objects
    end

    # Which scribable to use for the current request, should only return one scribable
    def scribable_for_request(request)
      instance_exec(request, &@scribable_for_request) if @scribable_for_request
    end

    # What to do after a site create (only for new sites, not imported sites)
    def after_site_create(site)
      instance_exec(site, &@after_site_create) if @after_site_create
    end
  end
end
