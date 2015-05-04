require "vcr"
require 'httparty'

module VcrSites
  module Flyingv
    def get_project_doc(project_url)
      VCR.use_cassette("flyingv") do
        response = HTTParty.get(project_url)
        Nokogiri::HTML(response)
      end
    end
  end
end
