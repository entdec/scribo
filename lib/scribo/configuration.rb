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
    attr_writer   :scribable_scope

    def initialize
      @logger = Logger.new(STDOUT)
      @logger.level = Logger::INFO
      @base_controller = '::ApplicationController'
      @supported_mime_types = {
          image:    %w[image/gif image/png image/jpeg image/bmp image/webp image/svg+xml],
          text:     %w[text/plain text/html text/css text/javascript application/javascript application/json application/xml],
          audio:    %w[audio/midi audio/mpeg audio/webm audio/ogg audio/wav],
          video:    %w[video/webm video/ogg video/mp4],
          document: %w[application/msword application/vnd.ms-powerpoint application/vnd.ms-excel application/pdf application/zip],
          font:     %w[font/collection font/otf font/sfnt font/ttf font/woff font/woff2 application/font-ttf application/vnd.ms-fontobject application/font-woff],
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
      @default_favicon_ico = "AAABAAEAEBAAAAEAIABoBAAAFgAAACgAAAAQAAAAIAAAAAEAIAAAAAAAAAQA\nAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA\nAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA\nAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA\nAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA\nAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA\nAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA\nAAAAAAAAAAAAAAAAAAAAAAAAAAAAAP8AAAAAAAAAAAAAAAAAAAAAAAAAAAAA\nAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA\n/wAAAP8AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA\nAAAAAAAAAAAAAAAAAAAAAAAAAP8AAAAAAAAA/wAAAAAAAAAAAAAAAAAAAAAA\nAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA/wAA\nAAAAAAD/AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA\nAAAAAAAAAAAAAAAAAAAAAAAAAAD/AAAAAAAAAP8AAAAAAAAAAAAAAAAAAAAA\nAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA7wAAAP8A\nAAAAAAAA/wAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA\nAAAAAAAAAAAAAAAAAAAAAADtAAAA/wAAAAAAAAC7AAAAAAAAAAAAAAAAAAAA\nAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAC8\nAAAA/wAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA\nAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA\nAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA\nAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA\nAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA\nAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA\nAAAAAAAA//8AAP//AAD//wAA//8AAPf/AAD5/wAA+v8AAP1/AAD+vwAA/l8A\nAP8vAAD/zwAA//8AAP//AAD//wAA//8AAA==\n"
    end

    # logger [Object].
    def logger
      @logger.is_a?(Proc) ? instance_exec(&@logger) : @logger
    end

    # By default all users can see all sites.
    # scribable_scope, provides you with the site-scope and allows you to tighten that visibility
    def scribable_scope(scope)
      scope = Scribo::Site.all unless scope
      scope = instance_exec(scope, &@scribable_scope) if @scribable_scope
    end
  end
end