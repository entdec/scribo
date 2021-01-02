# Scribo

A easy to use, embeddable CMS for Ruby on Rails.
Scribo is designed to work with your models and can also render your content inside customer designed layouts.

## Features

Scribo is designed to be easy to use and we try to keep it as simple as possible.
It's designed to have the least possible impact on your database, we only use two models/tables (Site and Content).
It also makes no assumptions about your data models, it does come feature packed though:

- Pages
- Blog (with permalinks & categories)
- Static assets
- Data files (think: make a page based on an Excel sheet)
- Layouts
- [Liquid](http://liquidmarkup.org) templating
- Mostly [Jekyll](https://jekyllrb.com) compatibile
- Use of [YAML](https://yaml.org) in front-matter and configuration
- Use of [Jekyll themes](https://jekyllrb.com/docs/themes/)

## Documentation

- [YAML](https://learn-the-web.algonquindesign.ca/topics/markdown-yaml-cheat-sheet/#yaml) cheatsheet
- Quick [YAML](https://learnxinyminutes.com/docs/yaml/) introduction

## API

The API uses token authorization, the token is obtained by making an sgid from the `scribable`.
So for a `scribable` model `Account`, you could create it as follows:

```ruby
token = Account.first.to_sgid(for: 'scribo', expires_in: nil).to_s
```

This token can be used in the below request.

### POST /api/sites/import

This allows you to import a site (in ZIP format) using an API token.

```shell
curl -H 'Authorization: Token {token}' -X POST -F 'files[]=@site.zip' https://endpoint/api/sites/import
```

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

The admin side of Scribo can be accessed here: https://localhost:3000/sites/

## Contributing

Bug reports and pull requests are welcome on GitHub at https://gitlab.com/entropydecelerator/scribo.
This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
