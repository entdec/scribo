# TODO

##### content-parts

- Based on 'name' and children content allow automatic content_for (content-part functionality)
    - Name must be unique per parent_id
    
    - /contact - page - layout: contact (with sidebar, body and address sections)
        - sidebar - content
        - body - content
        - address - content 
        
- Add content-part, replacing part of the content model, possibly making above first idea easier.

##### controller, view and path overrides

Allow users to override controllers and views (like devise), describe how this should be done.
This to enable admin pages with authentication, or regular content with authentication.
Or specific admin page requirements.

##### allow application helpers to be used in liquid

Starting with URL helpers to be able to more tightly integrate cms and app.

##### add configuration

This should enable the recursive lookups for content
Allow content types to be added easily

##### add request information to the context of liquid

~~So we can find out current path, see if content is active etc.~~

##### add export and import of sites

Export to zip, import from zip.
Partially done in Site.rb

##### add way to do redirects

##### how to separate sites

##### add properties/configuration to sites

##### fix issue with streaming mp4
See: https://stackoverflow.com/questions/28008564/streaming-mp4-in-chrome-with-rails-nginx-and-send-file
