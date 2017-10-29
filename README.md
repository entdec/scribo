# Scribo
A simple, embeddable CMS for Ruby on Rails. 
Scribo is designed to work with your models and can also render your content inside customer designed layouts.

## Usage
How to use my plugin.

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
model Domain
  scribable
end
```

You may need to add the following method to your ApplicationController:

```ruby
# Defines which site should be shown
def current_site
  
end
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

## Contributing
Contribution directions go here.

## License
The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
