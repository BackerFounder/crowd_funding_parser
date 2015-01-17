require "json"
require 'open-uri'
require "iconv"

module CrowdFundingParser
  module Parser
    class Kickstarter < General
      def initialize
        @parse_method = :json
        @jsons = []
      end

      def get_result(project_url)
        result = []
        Parallel.each(@jsons, in_precesses: 2, in_threads: 5) do |json|
          result << json if json["urls"]["web"]["project"] == project_url
        end
        result.first
      end

      def get_project_links(status = "online")
        status_code = get_status_code(status)
        @jsons = get_total_jsons
        @jsons.flatten!
        @jsons.compact!
        links = []
        Parallel.each(@jsons, in_precesses: 2, in_threads: 5) do |json|
          if json["state"] == status_code
            project_url = json["urls"]["web"]["project"]
            links << project_url
          end
        end
        links
      end

      def get_status_code(status)
        case status
        when "online"
          "live"
        when "preparing"
          3
        when "finished"
          "successful"
        else
          1
        end
      end

      def get_total_jsons
        jsons = []

        Parallel.each(1..210, in_precesses: 2, in_threads: 5) do |i|
          begin
            api_url = get_projects_page_api(i)
            json = get_json_through_url(api_url)["projects"]
            jsons << json
          rescue Exception => e
            puts e
            return false
          end
        end
        jsons
      end

      private

      def get_projects_page_api(page = 1)
        "https://www.kickstarter.com/projects/search.json?search=&page=#{page}"
      end

      # get data info

      def get_id(project_url)
        project_url.split("id=").last
      end

      def get_title(result)
        result["data"]["name"]
      end

      def get_category(result)

      end

      def get_creator_name(result)
        raw_creator_name = result["data"]["person"]["name"]
        encode_gbk_to_utf(raw_creator_name)
      end

      def get_creator_id(result)
        # json.css(".page-title-wrapper").css(".pageDes")[1].css("a").first["href"].split("/").last
      end

      def get_creator_link(result)
        # @url + json.css(".profilemeta .imp a").first["href"]
      end

      def get_summary(result)
        raw_summary = result["data"]["desc"]
        encode_gbk_to_utf(raw_summary)
      end

      # for tracking

      def get_money_goal(result)
        result["data"]["target-money"]
      end

      def get_money_pledged(result)
        result["data"]["curr-money"]
      end

      def get_backer_count(result)
        result["data"]["support_person"]
      end

      def get_last_time(result)
        result["data"]["remain_day"]
      end

      def get_status(last_time)
        if last_time == "0"
          "finished"
        else
          "online"
        end
      end

      def get_fb_count(result)
        
      end

      def get_following_count(result)
        result["data"]["focus_count"]
      end

      def get_backer_list(project_url)
        []
      end

      def encode_gbk_to_utf(string)
        begin
          Iconv.conv("utf-8//ignore", "gb2312//ignore", string)
        rescue Exception => e
          puts e
          string
        end
      end
    end
  end
end