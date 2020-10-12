# Scribo
A easy to use, embeddable CMS for Ruby on Rails.
Scribo is designed to work with your models and can also render your content inside customer designed layouts.

## Features
Scribo is designed to be easy to use and we try to keep it as simple as possible.
It's designed to have the least possible impact on your database, we only use two models/tables (Site and Content).
It also makes no assumptions about your data models, it does come feature packed though:

- Pages
- Posts (or articles)
- Static assets
- Data files
- Layouts
- [Liquid](http://liquidmarkup.org) templating

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'scribo'
```

Migrate your database:
```bash
$ bin/rails db:migrate
```

Then add Scribo to your routes file.
Scribo consumes all URLs, so make sure you put the following line at the bottom of your routes.rb.

```ruby
mount Scribo::Engine, at: '/'
```

## Using your controllers with scribo

In your controller add the following:
```ruby
render(scribo: current_site, path: '/index', restricted: false, owner: Account.first)
```

This will look for `index` in the `current_site`.

## Testing

bin/rails db:drop
bin/rails db:create
bin/rails db:migrate

## Contributing

Bug reports and pull requests are welcome on GitHub at https://gitlab.com/entropydecelerator/scribo.
This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License
The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
