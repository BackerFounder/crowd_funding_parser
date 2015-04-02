require "json"
require 'httparty'
require "iconv"

module CrowdFundingParser
  module Parser
    class Kickstarter < General
      include HTTParty
      def initialize
        # art = 1, comic = 3, game = 12,
        @category_ids = [1, 3, 6, 7, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 26]
        @parse_method = :doc
      end

      def platform_url
        "https://www.kickstarter.com"
      end

      def get_all_categories(status = "online")
        status_code = get_status_code(status)
        jsons = get_category_project_jsons(status_code)
        jsons.flatten.compact!
        categories = []
        Parallel.each(jsons, in_precesses: 2, in_threads: 5) do |json|
          category = { id: json["category"]["id"], name: json["category"]["name"], parent_id: json["category"]["parent_id"]}
          categories << category
        end
        categories.uniq
      end

      def get_project_links(status = "online")
        status_code = get_status_code(status)

        jsons = @category_ids.map do |category_id|
          category_jsons = get_category_project_jsons(status_code, category_id)
        end.flatten.compact

        Parallel.map(jsons, in_precesses: 2, in_threads: 5) do |json|
          unless json["state"] != "live" && json["pledged"].to_i == 0
            if json["state"] == status_code
              project_url = json["urls"]["web"]["project"]
            end
          end
        end
      end

      def get_category_project_jsons(status_code = "live", category_id = 0)
        jsons = []

        Parallel.each(1..200, in_precesses: 2, in_threads: 5) do |i|
          begin
            api_url = get_projects_page_api(i, status_code, category_id)
            json = get_json_through_url(api_url)["projects"]
            jsons << json
          rescue Exception => e
            Parallel::Stop
          end
        end
        jsons
      end

      private

      def get_project_page_api(project_url)
        project_url.split("?").first + ".json"
      end

      def get_projects_page_api(page = 1, status_code = "live", category_id = 0)
        "https://www.kickstarter.com/projects/search.json?page=#{page}&state=#{status_code}&category_id=#{category_id}"
      end

      def get_project_search_result_api(name)
        "https://www.kickstarter.com/projects/search.json?term=#{name}"
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
      rescue
        ""
      end

      def get_creator_link(result)
        if @parse_method == :doc
          creator_link = platform_url + result.css(".NS_projects__creator .col-8>h5 a.remote_modal_dialog").first["href"]
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

      def get_start_date(result)
        if @parse_method == :doc
          # no start date on page
        else
          Time.at(result["launched_at"])
        end
      end

      def get_end_date(result)
        if @parse_method == :doc
          result.css(".NS_projects__deadline_copy p.grey-dark time[datetime]").try(:first).try(:[], "datetime")
        else
          time = Time.at(result["deadline"])
        end
      end

      def get_region(result)
        if @parse_method == :doc
          get_string(result.css(".container-flex .h5 a.grey-dark:nth-child(1) b"))
        else
          result["location"]["displayable_name"]
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
          end_date = result.css("div[data-end_time]").try(:first).try(:[], "data-end_time") || Time.now.to_s
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

      def get_currency_string(result)
        if @parse_method == :doc
          result.css("data[data-currency]")[0]["data-currency"]
        else
          result["currency"]
        end
      end
    end
  end
end