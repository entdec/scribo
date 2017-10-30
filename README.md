# Scribo
A easy to use, embeddable CMS for Ruby on Rails. 
Scribo is designed to work with your models and can also render your content inside customer designed layouts.

## Features
Scribo is designed to be easy to use and we try to keep it as simple as possible.
It's designed to have the least possible impact on your database, we only use two models/tables (Site and Content).
It comes feature packed though:

### Shared path per site
All content within one site shares a path to be as similar to a regular site as possible.
This means your index.html can refer to a /img/logo.png just like you normally would.

### Nested layouts
Your blog articles can have an article layout, but still use your site-layout.

### [Liquid](http://liquidmarkup.org) templating
All text-based content is rendered through [liquid](http://liquidmarkup.org)
This means you can do powerful things with your pages, layouts but even stylesheets.

### Filters
Because we use [Slim](http://slim-lang.com) and [Tilt](https://github.com/rtomayko/tilt), all text-based content can be run through additional filters like Markdown, Slim, Haml and Sass. 

### Nested content (not enabled)
Content can have child content, this allows for blog-like structure (rendering is done by parent).
Child content will inherit the path of the parent.

## Installation
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

## Contributing
Contribution directions go here.

## License
The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
