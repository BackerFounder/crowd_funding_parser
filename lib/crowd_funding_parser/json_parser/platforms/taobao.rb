require "json"
module CrowdFundingParser
  module JsonParser
    class Taobao < General
      def initialize
        # status: 成功 = 2, 募資中 = 1, 預熱中 = 3
        @json_url = "http://hstar-hi.alicdn.com/dream/ajax/getProjectList.htm?page=4&pageSize=20&projectType=&type=6&status=&sort=&callback=jsonp"
      end

      def parse_tracking_data(json)
        project = Hash.new
        project['money_goal']      = json["target_money"].to_i
        project['money_pledged']   = json["curr_money"].to_i
        project['backer_count']    = json["buy_amount"].to_i
        project['last_time']       = json["remain_day"] + "天"
        project['status']          = get_status(json["status"])
        # project['backer_list']     = get_backer_list(project_url)
        project['fb_count']        = ""
        project['following_count'] = json["focus_count"]
        project
      end

      def parse_content_data(json)
        main_url = "http://hi.taobao.com/market/hi/detail2014.php?id="
        project = Hash.new
        project['platform_project_id'] = json["id"]
        project['title']         = json["name"]
        project['url']           = main_url + project["platform_project_id"]
        project['summary']       = ""
        project['category']      = get_category(json["category_id"])
        project['creator_name']  = ""
        project['creator_id']    = ""
        project['creator_link']  = ""
        project
      end

      def get_total_urls(status = 1)
        page_count = get_total_page(status)
        total_urls = []
        page_count.to_i.times do |i|
          total_urls << get_workable_url(i + 1, status)
        end
        total_urls
      end

      def get_total_jsons(status = 1)
        urls = get_total_urls(status)
        jsons = []
        urls.each do |url|
          page_json = turn_url_to_json(url)
          json = page_json["data"]
          jsons += json
        end
        jsons
      end

      def get_workable_url(page = 1, status = 1)
        "http://hstar-hi.alicdn.com/dream/ajax/getProjectList.htm?page=#{page}&pageSize=20&projectType=&type=6&status=#{status}"
      end

      def get_total_page(status = 1)
        url = "http://hstar-hi.alicdn.com/dream/ajax/getProjectList.htm?page=1&pageSize=20&projectType=&type=6&status=#{status}"
        json = turn_url_to_json(url)
        page_count = json["pageTotal"]
      end

      private

      def turn_url_to_json(url)
        open_url = open(url)
        json = JSON.load(open_url)
      end

      def get_status(status)
        if status.match("筹款中")
          "online"
        elsif status.match("制作中") || status.match("项目成功")
          "finished"
        elsif status.match("预热中")
          "preparing"
        else
          "online"
        end
      end

      def get_category(id)
        
      end
    end
  end
end