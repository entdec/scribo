# Scribo
A easy to use, embeddable CMS for Ruby on Rails. 
Scribo is designed to work with your models and can also render your content inside customer designed layouts.

## Features
Scribo is designed to be easy to use and we try to keep it as simple as possible.
It's designed to have the least possible impact on your database, we only use two models/tables (Site and Content).
It also makes no assumptions about your data models, it does come feature packed though:

- Shared path per site
- Nested layouts
- [Liquid](http://liquidmarkup.org) templating
- Filters
- Nested content (not enabled)

## Installation

Scribo depends on `commonmarker`, which needs `cmake` to compile, make sure you have this installed.

Add this line to your application's Gemfile:

```ruby
gem 'scribo'
```

And then install the migrations:
```bash
$ bin/rails scribo:install:migrations
```

And migrate your database:
```bash
$ bin/rails db:migrate
```

Then add Scribo to the bottom of your routes file:

```ruby
mount Scribo::Engine, at: '/'
```

## Rendering your content within a scribo layout

In your controller add the following:
```ruby
scribo_layout 'generic'
```

This will look for content with *identifier* 'generic' and render your content in that.

You'll get all your controller's class variables as additional context and those become available for liquid to use.
On top this, we also pass 'request' and 'content' as context.

The easiest possible layout would be:
```html
<html>
<head></head>
<body>{%yield%}</body>
</html>
```

## Testing

bin/rails db:drop
bin/rails db:create
bin/rails db:migrate

## Contributing

Bug reports and pull requests are welcome on GitHub at https://gitlab.com/entropydecelerator/scribo. 
This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License
The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
