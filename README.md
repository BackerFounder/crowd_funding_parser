[![Build Status](https://travis-ci.org/BackerFounder/crowd_funding_parser.svg)](https://travis-ci.org/BackerFounder/crowd_funding_parser)

# CrowdFundingParser

TODO: Write a gem description

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'crowd_funding_parser'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install crowd_funding_parser

## Usage

TODO: Write usage instructions here

## Contributing

1. Fork it ( https://github.com/[my-github-username]/crowd_funding_parser/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

### Add New Parser

#### 1. Add Test

##### What to test

There should be 18 methods that need to be tested:

1. ```get_id```
2. ```get_title```
3. ```get_category```
4. ```get_creator_name```
5. ```get_creator_id```
6. ```get_creator_link```
7. ```get_summary```
8. ```get_start_date```
9. ```get_end_date```
10. ```get_region```
11. ```get_currency_string```
12. ```get_money_goal```
13. ```get_money_pledged```
14. ```get_backer_count```
15. ```get_left_time```
16. ```get_status```
17. ```get_fb_count```
18. ```get_following_count```

##### How to write a test

First use `get_project_doc(campaign_page_url, platform_name)` to get test doc (please use a finished project).

And set expectations as the project's data(use `""` if no data).

Example spec is [flyingv_spec](https://github.com/BackerFounder/crowd_funding_parser/blob/master/spec/parsers/flyingv_spec.rb).

##### How to run test

We use `Rspec` to run our test, so just run `bundle exec rspec`.
Or you can run `bundle exec guard` to automatically run tests whenever you changed spec.
