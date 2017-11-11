# Content

To keep the CMS easy to use and not have to much impact on your existing database, 
all content is kept in one model: `Content`.
The field 'kind' is used to make a distinction between text-based content (text) and binary content (assets).

## Content
Text based content (kind: text) is meant for things like:
- Text (text/plain)
- HTML (text/html)
- JavaScript
- Stylesheets
- JSON
- XML

Text based content is always going through the liquid templating processor.

### Identified, named and located content

Some content has a path, namely content that should be directly available through a url or path, 
but some content doesn't need to be directly available (like layouts or included content), this is where the identifier comes into play.
Then there's named content, which is for future use and is for nested content elements (like sidebar, etc)

## Assets
Binary content (kind: assets) is meant for things like:
- Images
- Audio
- Video
- Documents (Word, Excel, Powerpoint, PDF's)
- Fonts
- Others (fe Zip)

Assets will always be served in the same way they are stored in the database.

## Fields

- kind: text or asset
- path: needs to be unique per site, indicates where content can be found
- content_type: content type of the content
- filter: how the content should be filtered (only for 'content' kind) - see: [Tilt](https://github.com/rtomayko/tilt)
- identifier: how the content can be indentified, needs to be unique per site
- name: name of the content, needs to be unique per site
- title: title of the content, can be used for your own purpose
- caption: caption of the content, can be used for your own purpose
- breadcrumb: breadcrumb of the content, can be used for your own purpose
- keywords: keywords of the content, can be used for your own purpose
- description: description of the content, can be used for your own purpose
- state: state of the content: draft, hidden, reviewed, published
- data: text or binary content
- properties: unused but reserved
