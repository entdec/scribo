module Scribo
  class Configuration
    attr_accessor :admin_authentication_module
    attr_accessor :base_controller
    attr_accessor :supported_mime_types
    attr_writer   :logger
    attr_accessor   :default_404_txt
    attr_accessor   :default_humans_txt
    attr_accessor   :default_robots_txt
    attr_accessor :default_favicon_ico
    attr_writer   :scribable_objects
    attr_writer   :site_for_uri
    attr_writer   :admin_mount_point
    attr_writer   :current_site

    def initialize
      @logger = Logger.new(STDOUT)
      @logger.level = Logger::INFO
      @base_controller = '::ApplicationController'
      @supported_mime_types = {
          image:    %w[image/gif image/png image/jpeg image/bmp image/webp image/svg+xml],
          text:     %w[text/plain text/html application/json application/xml],
          style:    %w[text/css],
          script:   %w[text/javascript application/javascript application/x-javascript],
          audio:    %w[audio/midi audio/mpeg audio/webm audio/ogg audio/wav],
          video:    %w[video/webm video/ogg video/mp4],
          document: %w[application/msword application/vnd.ms-powerpoint application/vnd.ms-excel application/pdf application/zip],
          font:     %w[font/collection font/otf font/sfnt font/ttf font/woff font/woff2 application/font-ttf application/x-font-ttf application/vnd.ms-fontobject application/font-woff],
          other:    %w[application/octet-stream]
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
        User-agent: *
        Disallow: /
      ROBOTS_TXT

      # Base64 encoded image/x-icon
      @default_favicon_ico = "AAABAAEAEBAAAAEAIABoBAAAFgAAACgAAAAQAAAAIAAAAAEAIAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAEcrEvoAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAsHIH/7d2Bv+3dgb/t3YG/7d2Bv0AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAt3YG/0crEv+3dgb/t3YG/7d2Bv8AAAAAt3YG/7d2Bv90Vx0DAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAALd2Bv+3dgb/t3YG/7d2Bv+3dgb/t3YG/7d2Bv+3dgb/t3YG/3VLBEwAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAC3dgb/t3YG/0crEv+3dgb/t3YG/7d2Bv+3dgb/t3YG/7d2Bv+3dgb+AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAt3YG/bd2Bv+3dgb/qGwI/7d2Bv+3dgb/t3YG/7d2Bv8AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAC3dgb/t3YG/7d2Bv+3dgb/t3YG/7d2Bv+3dgb/t3YG/7d2Bv+3dgb/AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAt3YG/7d2Bv+3dgb/lV8K/7d2Bv+3dgb/t3YG/7d2Bv+3dgb/t3YG/7h2B9EAAAAAAAAAAAAAAAAAAAAAAAAAALd2Bv+3dgb/t3YG/7d2Bv+JWAv/t3YG/7d2Bv+3dgb/t3YG/7d2Bv+3dgb/AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAt3YG/7d2Bv+3dgb/t3YG/7d2Bv+3dgb/t3YG/7d2Bv+3dgb/t3YG/wAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAALd2Bvi3dgb/t3YG+7d2Bv+3dgb/t3YG/7d2Bv+3dgb/t3YG/wAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAt3YG/wAAAAC3dgb/t3YG/7d2Bv+3dgb/t3YG/7d2Bv+3dgb/t3YG8AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAt3YG/7d2Bv+3dgb/t3YG/7d2Bv+3dgb/t3YG/7d2Bv8AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAC3dgb/t3YG/2hDA3O3dgb/t3YG/7d2Bv+3dgb/t3YG/QAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAC4dgeJAAAAALd2Bv+3dgb/t3YG/7d2Bv+zcgZ3//8AAL//AADB/wAAgn8AAIA/AACAHwAAgH8AAMAPAADABwAAwAcAAOAHAADgDwAA9AMAAPwDAAD+QQAA/6EAAA=="
      @current_site = ->(_options) { nil }
    end

    # logger [Object].
    def logger
      @logger.is_a?(Proc) ? instance_exec(&@logger) : @logger
    end

    # admin_mount_point [String].
    def admin_mount_point
      @admin_mount_point ||= '/scribo'
    end

    # By default all users can see all sites.
    # scribable_object is called when creating a new site, you can return your own object
    def scribable_objects
      [*instance_exec(&@scribable_objects)] if @scribable_objects
    end

    # Which site to use for a certain uri
    def site_for_uri(uri)
      instance_exec(uri, &@site_for_uri) if @site_for_uri
    end

    def current_site(options = {})
      instance_exec(options, &@current_site) if @current_site
    end
  end
end
