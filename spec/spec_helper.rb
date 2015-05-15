require "pry"
require "vcr"
require "crowd_funding_parser"
require "support/project_spec_support"
require 'webmock/rspec'
require "nokogiri"

VCR.configure do |config|
  config.cassette_library_dir = "spec/fixtures/vcr_cassettes"
  config.hook_into :webmock # or :fakeweb
end

RSpec.configure do |config|
  config.include ProjectSpecSupport
end
