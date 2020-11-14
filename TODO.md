# TODO

## General

- Fix issue with streaming mp4 in Safari
  See: https://stackoverflow.com/questions/28008564/streaming-mp4-in-chrome-with-rails-nginx-and-send-file

- Feature: Controller, view and path overrides
  Allow users to override controllers and views (like devise), describe how this should be done.
  This to enable admin pages with authentication, or regular content with authentication.
  Or specific admin page requirements.

## Site/Content

- Front-matter defaults - https://jekyllrb.com/docs/configuration/front-matter-defaults/

## Liquid

- Local tags
  Local tags (https://github.com/Shopify/liquid/pull/590) - a way to make tags only available for certain templates
  ie include should not be available for messages.
- Mail tag

## Jekyll compatibility

- Check filters from Jekyll: https://github.com/jekyll/jekyll/blob/c9b84e2b354067e61cf9878f27665c5c1c02481c/lib/jekyll/filters.rb
- Pagination: https://jekyllrb.com/docs/pagination/

  /blog/
  /blog/2/
  /blog/3/
  etc

## IDE

- Allow for multiple tabs and open editors
- Search for content
- Use localstorage for changes to prevent loss
- Allow export, preview from IDE
- Allow to go back to sites index
