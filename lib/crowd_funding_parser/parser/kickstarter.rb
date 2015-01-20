require "json"
require 'open-uri'
require "iconv"

module CrowdFundingParser
  module Parser
    class Kickstarter < General
      def initialize
        @parse_method = :doc
        @jsons = []
        @url = "https://www.kickstarter.com"
      end

      def get_result(project_url)
        if @jsons.present?
          result = []
          Parallel.each(@jsons, in_precesses: 2, in_threads: 5) do |json|
            result << json if json["urls"]["web"]["project"] == project_url
          end
          result.first
        else
          get_doc_through_url(project_url)
        end
      end

      def get_project_links(status = "online")
        status_code = get_status_code(status)
        @jsons = get_total_jsons(status_code)
        @jsons.flatten!
        @jsons.compact!
        links = []
        Parallel.each(@jsons, in_precesses: 2, in_threads: 5) do |json|
          project_url = json["urls"]["web"]["project"]
          links << project_url
        end
        @parse_method = :json
        links
      end

      private

      def get_project_page_api(project_url)
        project_url.split("?").first + ".json"
      end

      def get_projects_page_api(page = 1, status_code)
        "https://www.kickstarter.com/projects/search.json?search=&page=#{page}&state=#{status_code}"
      end

      def get_project_search_result_api(name)
        "https://www.kickstarter.com/projects/search.json?term=#{name}"
      end

      def get_total_jsons(status_code)
        jsons = []

        Parallel.each(1..210, in_precesses: 2, in_threads: 5) do |i|
          begin
            api_url = get_projects_page_api(i, status_code)
            json = get_json_through_url(api_url)["projects"]
            jsons << json
          rescue Exception => e
            puts e
          end
        end
        jsons
      end

      def get_status_code(status)
        case status
        when "online"
          "live"
        when "finished"
          "successful"
        else
          "live"
        end
      end

      # get data info

      # def get_id(project_url)
      #   regex = /\/(\d{5,}+)\/([a-zA-z0-9-]+)/
      #   regex.match(project_url)[2]
      #   # project_url.split("/").last.split("?").first
      # end

      def get_title(result)
        if @parse_method == :doc
          get_string(result.css(".NS_projects__header h2 .green-dark"))
        else
          result["name"]
        end
      end

      def get_category(result)
        if @parse_method == :doc
          get_string(result.css(".container-flex .h5 a.grey-dark:nth-child(2) b"))
        else
          result["category"]["name"]
        end
      end

      def get_creator_name(result)
        if @parse_method == :doc
          get_string(result.css(".NS_projects__creator .col-8>h5 a.remote_modal_dialog"))
        else
          result["creator"]["name"]
        end
      end

      def get_creator_id(result)
        if @parse_method == :doc
          creator_link = result.css(".NS_projects__creator .col-8>h5 a.remote_modal_dialog").first["href"]
          creator_link.split("/")[-3]
        else
          result["creator"]["id"]
        end
      end

      def get_creator_link(result)
        if @parse_method == :doc
          creator_link = @url + result.css(".NS_projects__creator .col-8>h5 a.remote_modal_dialog").first["href"]
        else
          result["creator"]["urls"]["web"]["user"]
        end
      end

      def get_summary(result)
        if @parse_method == :doc
          get_string(result.css(".container-flex .col-8 .mobile-hide p.h3.mb3"))
        else
          result["blurb"]
        end
      end

      # for tracking

      def get_money_goal(result)
        if @parse_method == :doc
          result.css("div[data-pledged]").first["data-goal"]
        else
          result["goal"]
        end
      end

      def get_money_pledged(result)
        if @parse_method == :doc
          result.css("div[data-pledged]").first["data-pledged"]
        else
          result["pledged"]
        end
      end

      def get_backer_count(result)
        if @parse_method == :doc
          result.css("div[data-backers-count]").first["data-backers-count"]
        else
          result["backers_count"]
        end
      end

      def get_last_time(result)
        if @parse_method == :doc
          end_date = result.css("div[data-end_time]").first["data-end_time"]
          last_seconds = Time.parse(end_date) - Time.now
        else
          last_seconds = result["deadline"].to_i - Time.now.to_i
        end
        last_day = last_seconds.to_i / 86400
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