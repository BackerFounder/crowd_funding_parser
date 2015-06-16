module CrowdFundingParser
  module Parser
    class Flyingv < General
      def initialize
        @platform_url = "http://www.flyingv.cc"
        @item_css_class = ".portfolio-item"
        @status_css_class = ".unit-time"
      end

      def get_lists
        categories = ["designgoods", "media", "stageplay", "entertainment", "publish", "society", "technology", "food", "travel"]
        categories.map do |category|
          category_url = @platform_url + "/category/#{category}"
          HTTParty.get(category_url, verify: false)
        end
      end

      MethodBuilder.set_methods do
        insert_parser "Flyingv"

        set_variable do
          @platform_url = "http://www.flyingv.cc"
          @time_regex = /(\d{4}\/\d{2}\/\d{2}).+(\d{4}\/\d{2}\/\d{2})/
        end

        set_method :get_title do |doc|
          get_string(doc.css(".page-title-wrapper").css(".pagesTitle"))
        end

        set_method :get_category do |doc|
          doc.css(".page-title-wrapper").css(".pageDes").first.css("a").first.text
        end

        set_method :get_creator_name do |doc|
          doc.css(".page-title-wrapper").css(".pageDes")[1].css("a").first.text.strip
        end

        set_method :get_creator_id do |doc|
          doc.css(".page-title-wrapper").css(".pageDes")[1].css("a").first["href"].split("/").last
        end

        set_method :get_creator_link do |doc|
          @platform_url + doc.css(".profilemeta .imp a").first["href"]
        end

        set_method :get_summary do |doc|
          doc.css(".project_content").first.text.to_s[0..500].strip
        end

        set_method :get_start_date do |doc|
          text = get_string(doc.css(".col-xs-4.sidebarprj")).gsub(/\n/, "")
          @time_regex.match(text)[1]
        end

        set_method :get_end_date do |doc|
          text = get_string(doc.css(".col-xs-4.sidebarprj")).gsub(/\n/, "")
          @time_regex.match(text)[2]
        end

        set_method :get_region do |doc|
          "Taiwan"
        end

        set_method :get_money_goal do |doc|
          money_string(get_string(doc.css(".countdes .dt .white")))
        end

        set_method :get_money_pledged do |doc|
          money_string(get_string(doc.css(".countdes .ut .rtt h3")))
        end

        set_method :get_backer_count do |doc|
          get_string(doc.css(".countdes .dt .pull-right")).sub("人贊助", "")
        end

        set_method :get_left_time do |doc|
          get_string(doc.css(".countdes .dt div:nth-child(2)")).sub("剩餘", "")
        end

        set_method :get_status do |left_time|
          if left_time.match("已結束")
            "finished"
          elsif left_time.match("開始")
            "preparing"
          else
            "online"
          end
        end

        set_method :get_fb_count do |doc|
          get_string(doc.css("#fbBtn .sharenumber"))
        end

        set_method :get_following_count do |doc|
          get_string(doc.css(".sidebarprj h5")).sub("人追踨", "").sub("追蹤", "").strip
        end

        set_method :get_currency_string do |result|
          "twd"
        end
      end
    end
  end
end
