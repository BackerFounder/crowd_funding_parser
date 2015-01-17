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
        if @jsons.present?
          result = []
          Parallel.each(@jsons, in_precesses: 2, in_threads: 5) do |json|
            result << json if json["urls"]["web"]["project"] == project_url
          end
          result.first
        else
          project_name = project_url.split("/").last.split("?").first
          projects_api = get_project_search_result_api(project_name)
          if json = get_json_through_url(projects_api)
            result = json["projects"].first
          end
        end
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

      def get_project_search_result_api(name)
        "https://www.kickstarter.com/projects/search.json?term=#{name}"
      end

      # get data info

      def get_id(project_url)
        project_url.split("/").last
      end

      def get_title(result)
        result["name"]
      end

      def get_category(result)
        result["category"]["name"]
      end

      def get_creator_name(result)
        result["creator"]["name"]
      end

      def get_creator_id(result)
        result["creator"]["id"]
      end

      def get_creator_link(result)
        result["creator"]["urls"]["web"]["user"]
      end

      def get_summary(result)
        result["blurb"]
      end

      # for tracking

      def get_money_goal(result)
        result["goal"]
      end

      def get_money_pledged(result)
        result["pledged"]
      end

      def get_backer_count(result)
        result["backers_count"]
      end

      def get_last_time(result)
        last_seconds = result["deadline"].to_i - Time.now.to_i
        last_day = last_seconds / 86400
        if last_day <= 0
          "已結束"
        else
          last_day.to_s + "天"
        end
      end

      def get_status(last_time)
        if last_time == "已結束"
          "finished"
        else
          "online"
        end
      end

      def get_fb_count(result)
        
      end

      def get_following_count(result)
        
      end

      def get_backer_list(project_url)
        []
      end
    end
  end
end