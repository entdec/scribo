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

### Path

All content has a path, and is directly available through a url or path. You can also make it not directly available by using an underscore in the path.

## Assets
Binary content (kind: assets) is meant for things like:
- Images
- Audio
- Video
- Documents (Word, Excel, Powerpoint, PDF's)
- Fonts
- Others (fe zip)
- Everything else

Assets will always be served in the same way they are stored in the database.

