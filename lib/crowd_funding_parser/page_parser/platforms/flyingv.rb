require 'open-uri'

module CrowdFundingParser
  module PageParser
    class Flyingv < General
      def initialize(*cat)
        categories = cat.empty? ? ["designgoods", "media", "stageplay", "entertainment", "publish", "society", "technology", "food", "travel"] : cat
        @url = "https://www.flyingv.cc"
        @targets = []

        categories.each do |category|
          category_url = @url + "/category/#{category}"
          @targets << open(category_url)
        end

        @item_css_class = ".portfolio-item"
        @status_css_class = ".unit-time"
      end

      # for project's info
      def get_id(rel_url)
        rel_url.split("/").last
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

      def get_status(last_time)
        if last_time.match("已結束")
          "finished"
        elsif last_time.match("開始")
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