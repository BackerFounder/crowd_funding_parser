require "json"
require 'open-uri'
require "iconv"

module CrowdFundingParser
  module Parser
    class Taobao < General
      def initialize
        @parse_method = :json
        @url = "http://hi.taobao.com/market/hi/detail2014.php?id="
      end

      def get_project_links(status = "online")
        status_code = get_status_code(status)
        jsons = get_total_jsons(status_code)
        links = []

        Parallel.each(jsons, in_precesses: 2, in_threads: 5) do |json|
          project_id = json["id"].to_s
          project_url = @url + project_id
          links << project_url
        end
        links
      end

      def get_status_code(status)
        case status
        when "online"
          1
        when "preparing"
          3
        when "finished"
          2
        else
          1
        end
      end

      def get_total_jsons(status = 1)
        urls = get_total_json_apis(status)
        jsons = []
        urls.each do |url|
          page_json = get_json_through_url(url)
          json = page_json["data"]
          jsons += json
        end
        jsons
      end

      def get_total_json_apis(status = 1)
        page_count = get_total_page(status)
        total_urls = []
        page_count.to_i.times do |i|
          total_urls << get_projects_page_api(i + 1, status)
        end
        total_urls
      end

      def get_total_page(status = 1)
        url = "http://hstar-hi.alicdn.com/dream/ajax/getProjectList.htm?page=1&pageSize=20&projectType=&type=6&status=#{status}"
        json = get_json_through_url(url)
        page_count = json["pageTotal"]
      end

      private

      def get_project_api(project_id)
        "http://hstar-hi.alicdn.com/dream/ajax/getProjectForDetail.htm?id=#{project_id}"
      end

      def get_projects_page_api(page = 1, status = 1)
        "http://hstar-hi.alicdn.com/dream/ajax/getProjectList.htm?page=#{page}&pageSize=20&projectType=&type=6&status=#{status}"
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
        result["data"]["target_money"]
      end

      def get_money_pledged(result)
        result["data"]["curr_money"]
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
        # if result["remain_day"] == "0" && result["plan_end_days"] == ["0"]
        #   "finished"
        # elsif result["plan_end_days"] != ["0"]
        #   "preparing"
        # else
        #   "online"
        # end
      end

      def get_fb_count(result)
        
      end

      def get_following_count(result)
        result["data"]["focus_count"]
      end

      def get_backer_list(project_url)
        []
      end

      def get_currency_string(result)
        "cny"
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