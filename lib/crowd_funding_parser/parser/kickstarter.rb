require "json"
require "iconv"

module CrowdFundingParser
  module Parser
    class Kickstarter < General
      def initialize
        @platform_url = "https://www.kickstarter.com"
        @category_ids = [1, 3, 6, 7, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 26]
        @parse_method = :doc
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

      def get_project_search_doc_api(name)
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

      MethodBuilder.set_methods do
        insert_class "Kickstarter"

        set_variable do
          @platform_url = "https://www.kickstarter.com"
        end

        set_method :get_title do |doc|
          get_string(doc.css(".NS_projects__header h2 .green-dark"))
        end

        set_method :get_category do |doc|
          get_string(doc.css(".container-flex .h5 a.grey-dark:nth-child(2) b"))
        end

        set_method :get_creator_name do |doc|
          get_string(doc.css(".NS_projects__creator .col-8>h5 a.remote_modal_dialog"))
        end

        set_method :get_creator_id do |doc|
          creator_path = doc.css(".NS_projects__creator .col-8>h5 a.remote_modal_dialog").first["href"]
          creator_path.split("/")[-3]
        end

        set_method :get_creator_link do |doc|
          @platform_url + doc.css(".NS_projects__creator .col-8>h5 a.remote_modal_dialog").first["href"]
        end

        set_method :get_summary do |doc|
          get_string(doc.css(".container-flex .col-8 .mobile-hide p.h3.mb3"))
        end

        set_method :get_start_date do |doc|
          ""
        end

        set_method :get_end_date do |doc|
          doc.css(".NS_projects__deadline_copy p.grey-dark time[datetime]").try(:first).try(:[], "datetime")
        end

        set_method :get_region do |doc|
          get_string(doc.css(".container-flex .h5 a.grey-dark:nth-child(1) b"))
        end

        set_method :get_money_pledged, reuse: true do |doc|
          doc.css("div[data-pledged]").first["data-pledged"]
        end

        set_method :get_money_goal do |doc|
          doc.css("div[data-pledged]").first["data-goal"]
        end

        set_method :get_backer_count do |doc|
          doc.css("div[data-backers-count]").first["data-backers-count"]
        end

        set_method :get_last_time do |doc|
          end_date = doc.css("div[data-end_time]").try(:first).try(:[], "data-end_time") || Time.now.to_s
          last_seconds = Time.parse(end_date) - Time.now
          last_day = last_seconds.to_i / 86400
          if last_day <= 0
            "已結束"
          else
            last_day.to_s + "天"
          end
        end

        set_method :get_status do |last_time|
          if last_time == "已結束"
            "finished"
          else
            "online"
          end
        end

        set_method :get_fb_count do
          ""
        end
        set_method :get_following_count do
          ""
        end
        set_method :get_currency_string do |doc|
          doc.css("data[data-currency]")[0]["data-currency"]
        end
      end
    end
  end
end