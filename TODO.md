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

##### fix issue with streaming mp4
See: https://stackoverflow.com/questions/28008564/streaming-mp4-in-chrome-with-rails-nginx-and-send-file


## Bucket

##### add properties/configuration to buckets

## Other

##### controller, view and path overrides

Allow users to override controllers and views (like devise), describe how this should be done.
This to enable admin pages with authentication, or regular content with authentication.
Or specific admin page requirements.

##### add configuration

This should enable the recursive lookups for content

##### GUI/WYSIWYG

##### Switch to nested set

https://github.com/collectiveidea/awesome_nested_set (why again?)


## Liquid

##### Local tags
Local tags (https://github.com/Shopify/liquid/pull/590) - a way to make tags only available for certain templates
ie include should not be available for messages.
