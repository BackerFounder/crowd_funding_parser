require 'open-uri'

module CrowdFundingParser
  module PageParser
    class Webackers < General
      def initialize(*cat)
        categories = cat.empty? ? ["ART", "PUBLICATION", "MUSIC", "DESIGN", "TECHNOLOGY", "ACG", "SURPRISE", "CHARITY", "VIDEO"] : cat
        @url = "http://www.webackers.com"
        @targets = []

        categories.each do |category|
          category_url = @url + "/Proposal/Browse?queryType=ALL&fundedStatus=ALL&category=#{category}"
          @targets << open(category_url)
        end

        @item_css_class = ".cbp-item"
        @status_css_class = "li.timeitem"
      end

      # for project's info
      def get_id(rel_url)
        rel_url.split("/").last
      end

      def get_title(doc)
        get_string(doc.css(".case_header .case_title"))
      end

      def get_category(doc)
       get_string(doc.css(".case_header .case_category a"))
      end

      def get_creator_name(doc)
        get_string(doc.css(".headphoto_detail .name a"))
      end

      def get_creator_id(doc)
        doc.css(".headphoto_detail .name a").first["href"].split("/").last
      end

      def get_creator_link(doc)
        @url + doc.css(".headphoto_detail .name a").first["href"]
      end

      def get_summary(doc)
        doc.css(".tab-content .description").first.text.to_s[0..500].strip
      end

      # for tracking

      def get_money_goal(doc)
        money_string(get_string(doc.css(".money_target")))
      end

      def get_money_pledged(doc)
        money_string(get_string(doc.css(".money_now")))
      end

      def get_backer_count(doc)
        get_string(doc.css(".tabbable li:nth-child(3) .badge.bg_no"))
      end

      def get_last_time(doc)
        time_string = get_string(doc.css("article:nth-child(4) .panel-body span:nth-child(2)"))
        last_seconds = (Time.parse(time_string) - Time.now)
        last_seconds <= 0 ? "已結束" : convert_time(last_seconds)
      end

      def get_status(last_time)
        if last_time.match("已結束") || last_time.match("已完成")
          "finished"
        elsif last_time.match("開始")
          "preparing"
        else
          "online"
        end
      end

      def get_fb_count(doc)
        # get 0 because of ajax delay
        get_string(doc.css(".fbBtn span.fb_share_count"))
      end

      def get_following_count(doc)
        get_string(doc.css(".badge_share"))
      end

      def get_backer_list(project_url)
        []
      end
    end
  end
end