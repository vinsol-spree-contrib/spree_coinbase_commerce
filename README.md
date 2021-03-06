# SpreeCoinbaseCommerce

[WIP] This gem has not been tested as Coinbase commerce api doesnot provide any sandbox environment. it would be great if someone can check and report if any issues are faced.

# Demo
-----------------------------------


Try SpreeCoinbaseCommerce for Spree 3-4 with direct deployment on Heroku:

[![Deploy](https://www.herokucdn.com/deploy/button.svg)](https://heroku.com/deploy?template=https://github.com/vinsol-spree-contrib/spree-demo-heroku/tree/spree-coinbase-commerce-3.4)

## Installation

1. Add this extension to your Gemfile with this line:
  ```ruby
  gem 'coinbase_commerce', github: 'vinsol/coinbase_commerce'
  gem 'spree_coinbase_commerce', github: 'vinsol-spree-contrib/spree_coinbase_commerce'
  ```

2. Install the gem using Bundler:
  ```ruby
  bundle install
  ```

3. Copy & run migrations
  ```ruby
  bundle exec rails g spree_coinbase_commerce:install
  ```

4. Restart your server

  If your server was running, restart it so that it can find the assets properly.

## Testing

First bundle your dependencies, then run `rake`. `rake` will default to building the dummy app if it does not exist, then it will run specs. The dummy app can be regenerated by using `rake test_app`.

```shell
bundle
bundle exec rake
```

When testing your applications integration with this extension you may use it's factories.
Simply add this require statement to your spec_helper:

```ruby
require 'spree_coinbase_commerce/factories'
```


## Contributing

If you'd like to contribute, please take a look at the
[instructions](CONTRIBUTING.md) for installing dependencies and crafting a good
pull request.

Copyright (c) 2018 [name of extension creator], released under the New BSD License
