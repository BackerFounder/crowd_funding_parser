require "json"
module CrowdFundingParser
  module JsonParser
    class Taobao < General
      def initialize
        # status: 成功 = 2, 募資中 = 1, 預熱中 = 3
        @json_url = "http://hstar-hi.alicdn.com/dream/ajax/getProjectList.htm?page=4&pageSize=20&projectType=&type=6&status=&sort=&callback=jsonp"
        @url = "http://hi.taobao.com/market/hi/detail2014.php?id="
      end

      def get_project_links(status = 1)
        jsons = get_total_jsons(status)
        links = []

        jsons.each do |json|
          project_id = json["id"].to_s
          project_url = @url + project_id
          links << project_url
        end
        links
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

      def get_total_urls(status = 1)
        page_count = get_total_page(status)
        total_urls = []
        page_count.to_i.times do |i|
          total_urls << get_workable_url(i + 1, status)
        end
        total_urls
      end

      def get_total_page(status = 1)
        url = "http://hstar-hi.alicdn.com/dream/ajax/getProjectList.htm?page=1&pageSize=20&projectType=&type=6&status=#{status}"
        json = turn_url_to_json(url)
        page_count = json["pageTotal"]
      end

      def get_workable_url(page = 1, status = 1)
        "http://hstar-hi.alicdn.com/dream/ajax/getProjectList.htm?page=#{page}&pageSize=20&projectType=&type=6&status=#{status}"
      end

      private

      def turn_url_to_json(url)
        open_url = open(url)
        json = JSON.load(open_url)
      end

      def get_title(doc)
        get_string(doc.css(".page-title-wrapper").css(".pagesTitle"))
      end

      def get_category(doc)
        doc.css(".page-title-wrapper").css(".pageDes").first.css("a").first.text
      end

      def get_creator_name(doc)
        doc.css(".page-title-wrapper").css(".pageDes")[1].css("a").first.text.strip
      end

      def get_creator_id(doc)
        doc.css(".page-title-wrapper").css(".pageDes")[1].css("a").first["href"].split("/").last
      end

      def get_creator_link(doc)
        @url + doc.css(".profilemeta .imp a").first["href"]
      end

      def get_summary(doc)
        doc.css(".project_content").first.text.to_s[0..500].strip
      end

      # for tracking

      def get_money_goal(doc)
        money_string(get_string(doc.css(".countdes .dt .white")))
      end

      def get_money_pledged(doc)
        money_string(get_string(doc.css(".countdes .ut .rtt h3")))
      end

      def get_backer_count(doc)
        get_string(doc.css(".countdes .dt .pull-right")).sub("人贊助", "")
      end

      def get_last_time(doc)
        get_string(doc.css(".countdes .dt div:nth-child(2)")).sub("剩餘", "")
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

      def get_fb_count(doc)
        get_string(doc.css("#fbBtn .sharenumber"))
      end

      def get_following_count(doc)
        get_string(doc.css(".sidebarprj h5")).sub("人追踨", "").sub("追蹤", "").strip
      end

      def get_backer_list(project_url)
        []
      end
    end
  end
end