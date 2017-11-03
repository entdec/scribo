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

Tell scribable which models can have sites by adding the following line to your model:

```ruby
  scribable
```

So say you have a 'Domain' class, which can have multiple sites, you would do the following:

```ruby
def Domain
  scribable
end
```

You may need to add the following method to your ApplicationController and make it available as a helper:

```ruby
# Defines which site should be shown
def current_site
  
end
helper_method :current_site
```

It should return which site should currently be shown.
By default scribo will take the first site available, this may be fine for development or for your situation, but be aware. 

So again, say you have a 'Domain' class, which can have multiple sites, you could something similar to the following:

```ruby
# Defines which site should be shown
def current_site
  Domain.sites.named(request.env['SERVER_NAME']).first  
end
```

Then add Scribo to the bottom of your routes file:

```ruby
mount Scribo::Engine, at: '/'
```

## Rendering your content within a scribo layout

You can define a regular layout, which will be picked up by your controller and add the following:
```slim
= layout_with_scribo('customer_layout', yield, domain: @domain)
```

This will look for content with *identifier* 'customer_layout' and render your content in that.
Here we also pass an additional context so that 'domain' becomes available for liquid to use.
On top of your own context, we also pass 'request' and 'content' as context.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://gitlab.com/tdegrunt/scribo. 
This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License
The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
