# Scribo
A simple, embeddable CMS for Ruby on Rails. Scribo is designed to work with your models and renders your content inside customer designed layouts.

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

Then add Scribo to the bottom of your routes file:

```ruby
mount Scribo::Engine, at: '/'
```

## Contributing
Contribution directions go here.

## License
The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
