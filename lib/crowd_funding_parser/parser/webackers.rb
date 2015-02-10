require 'httparty'

module CrowdFundingParser
  module Parser
    class Webackers < General
      include HTTParty

      def platform_url
        "http://www.webackers.com"
      end

      def get_lists
        categories = ["ART", "PUBLICATION", "MUSIC", "DESIGN", "TECHNOLOGY", "ACG", "SURPRISE", "CHARITY", "VIDEO"]
        categories.map do |category|
          category_url = platform_url + "/Proposal/Browse?queryType=ALL&fundedStatus=ALL&category=#{category}"
          HTTParty.get(category_url)
        end
      end

      def item_css_class
        ".cbp-item"
      end

      def status_css_class
        "li.timeitem"
      end

      # for project's info

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
        platform_url + doc.css(".headphoto_detail .name a").first["href"]
      end

      def get_summary(doc)
        doc.css(".tab-content .description").first.text.to_s[0..500].strip
      end

      def get_start_date(doc)
        
      end

      def get_end_date(doc)
        date_string = get_string(doc.css(".container .col-md-3 .panel-body.bg_gray_h.fa-gray_d span:nth-child(2)"))
        Date.parse(date_string)
      end

      def get_region(doc)
        "Taiwan"
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

      def get_currency_string(result)
        "twd"
      end
    end
  end
end