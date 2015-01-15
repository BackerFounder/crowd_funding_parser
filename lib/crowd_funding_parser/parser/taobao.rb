require "json"
require 'open-uri'
require 'watir'

module CrowdFundingParser
  module Parser
    class Taobao < General
      def initialize
        @parse_method = :json
        # status: 成功 = 2, 募資中 = 1, 預熱中 = 3
        @page_json_url = "http://hstar-hi.alicdn.com/dream/ajax/getProjectList.htm?page=4&pageSize=20&projectType=&type=6&status=&sort=&callback=jsonp"
        @url = "http://hi.taobao.com/market/hi/detail2014.php?id="
      end

      def get_project_links(status = "online")
        status_code = get_status_code(status)
        jsons = get_total_jsons(status_code)
        links = []

        jsons.each do |json|
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

      def get_id(project_url)
        project_url.split("id=").last
      end

      def get_title(doc)
        get_string(doc.css(".project-title h1"))
      end

      def get_category(doc)
        
      end

      def get_creator_name(doc)
        get_string(doc.css("span.sponsor-name"))
      end

      def get_creator_id(doc)
        # doc.css(".page-title-wrapper").css(".pageDes")[1].css("a").first["href"].split("/").last
      end

      def get_creator_link(doc)
        # @url + doc.css(".profilemeta .imp a").first["href"]
      end

      def get_summary(doc)
        summarize_project_content(get_string(doc.css("#J_Desc")))
      end

      # for tracking

      def get_money_goal(doc)
        money_string(get_string(doc.css(".target-money em")))
      end

      def get_money_pledged(doc)
        money_string(get_string(doc.css(".current-money")))
      end

      def get_backer_count(doc)
        get_string(doc.css(".projects-schedule-data .data-number:nth-child(1)"))
      end

      def get_last_time(doc)
        get_string(doc.css(".projects-schedule-data .data-number:nth-child(2)"))
      end

      def get_status(doc)
        status = get_string(doc.css("a.reserve-btn.J_ReserveBtn"))
        if status.match("我要支持")
          "online"
        elsif status.match("筹款结束") || status.match("项目成功")
          "finished"
        elsif status.match("我喜欢")
          "preparing"
        else
          "online"
        end
      end

      def get_fb_count(doc)
        
      end

      def get_following_count(doc)
        get_string(doc.css("span.J_LikeNum"))
      end

      def get_backer_list(project_url)
        []
      end
    end
  end
end