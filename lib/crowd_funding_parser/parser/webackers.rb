module CrowdFundingParser
  module Parser
    class Webackers < General
      def initialize
        @platform_url = "http://www.webackers.com"
        @item_css_class = ".cbp-item"
        @status_css_class = "li.timeitem"
      end

      def get_lists
        categories = ["ART", "PUBLICATION", "MUSIC", "DESIGN", "TECHNOLOGY", "ACG", "SURPRISE", "CHARITY", "VIDEO"]
        categories.map do |category|
          category_url = @platform_url + "/Proposal/Browse?queryType=ALL&fundedStatus=ALL&category=#{category}"
          HTTParty.get(category_url)
        end
      end

      MethodBuilder.set_methods do
        insert_class "Webackers"

        set_variable do
          @platform_url = "http://www.webackers.com"
        end

        set_method :get_title do |doc|
          get_string(doc.css(".case_header .case_title"))
        end

        set_method :get_category do |doc|
          get_string(doc.css(".case_header .case_category a"))
        end

        set_method :get_creator_name do |doc|
          get_string(doc.css(".headphoto_detail .name a"))
        end

        set_method :get_creator_id do |doc|
          doc.css(".headphoto_detail .name a").first["href"].split("/").last
        end

        set_method :get_creator_link do |doc|
          @platform_url + doc.css(".headphoto_detail .name a").first["href"]
        end

        set_method :get_summary do |doc|
          doc.css(".tab-content .description").first.text.to_s[0..500].strip
        end

        set_method :get_end_date do |doc|
          date_string = get_string(doc.css(".container .col-md-3 .panel-body.bg_gray_h.fa-gray_d span:nth-child(2)"))
          Date.parse(date_string)
        end

        set_method :get_region do |doc|
          "Taiwan"
        end

        set_method :get_money_goal do |doc|
          money_string(get_string(doc.css(".money_target")))
        end

        set_method :get_money_pledged do |doc|
          money_string(get_string(doc.css(".money_now")))
        end

        set_method :get_backer_count do |doc|
          get_string(doc.css(".tabbable li:nth-child(3) .badge.bg_no"))
        end

        set_method :get_last_time do |doc|
          time_string = get_string(doc.css("article:nth-child(4) .panel-body span:nth-child(2)"))
          last_seconds = (Time.parse(time_string) - Time.now)
          last_seconds <= 0 ? "已結束" : convert_time(last_seconds)
        end

        set_method :get_status do |last_time|
          if last_time.match("已結束") || last_time.match("已完成")
            "finished"
          elsif last_time.match("開始")
            "preparing"
          else
            "online"
          end
        end

        set_method :get_fb_count do |doc|
          get_string(doc.css(".fbBtn span.fb_share_count"))
        end

        set_method :get_following_count do |doc|
          get_string(doc.css(".badge_share"))
        end

        set_method :get_currency_string do |result|
          "twd"
        end
      end
    end
  end
end