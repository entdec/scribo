# TODO

## Content 

##### content-parts

- Based on 'name' and children content allow automatic content_for (content-part functionality)
    - Name must be unique per parent_id
    
    - /contact - page - layout: contact (with sidebar, body and address sections)
        - sidebar - content
        - body - content
        - address - content 
        
- Add content-part, replacing part of the content model, possibly making above first idea easier.

##### allow application helpers to be used in liquid content

Starting with URL helpers to be able to more tightly integrate cms and app.

##### add request information to the context of liquid

~~So we can find out current path, see if content is active etc.~~

##### fix issue with streaming mp4
See: https://stackoverflow.com/questions/28008564/streaming-mp4-in-chrome-with-rails-nginx-and-send-file

~~add way to do redirects~~

## Site

##### add export and import of sites

Export to zip, import from zip.
Partially done in Site.rb

##### how to separate sites

This is pretty much left up to the user, because it depends per application, but perhaps we should offer default?

##### add site maintenance

##### add properties/configuration to sites

## Other

##### controller, view and path overrides

Allow users to override controllers and views (like devise), describe how this should be done.
This to enable admin pages with authentication, or regular content with authentication.
Or specific admin page requirements.

##### add configuration

This should enable the recursive lookups for content
Allow content types to be added easily
