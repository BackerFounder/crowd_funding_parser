module CrowdFundingParser
  module Parser
    class Zeczec < General

      def initialize
        @platform_url = "https://www.zeczec.com"
        @item_css_class = ".project-list .span4"
        @status_css_class = ".meta span:nth-child(2)"
      end

      def get_lists
        [HTTParty.get(@platform_url + "/categories")]
      end

      MethodBuilder.set_methods do
        insert_class "Zeczec"

        set_variable do
          @platform_url = "https://www.zeczec.com"
          @time_regex = /\d{4}\/\d{2}\/\d{2}/
        end

        set_method :get_title do |doc|
          get_string(doc.css("a.project-title"))
        end

        set_method :get_category do |doc|
          doc.css(".project-meta").css("a")[0].text
        end

        set_method :get_creator_name do |doc|
          doc.css(".project-meta").css("a")[1].text.strip
        end

        set_method :get_creator_id do |doc|
          doc.css(".project-meta").css("a")[1]["href"].split("/").last
        end

        set_method :get_creator_link do |doc|
          @platform_url + doc.css(".creator .fly-center a").first["href"]
        end

        set_method :get_summary do |doc|
          doc.css(".project-content").first.text.to_s[0..500].strip
        end

        set_method :get_start_date do |doc|
          text = get_string(doc.css(".sidebar .project-notice"))
          text.scan(@time_regex).sort.first
        end

        set_method :get_end_date do |doc|
          text = get_string(doc.css(".sidebar .project-notice"))
          text.scan(@time_regex).sort.last
        end

        set_method :get_region do |doc|
          "Taiwan"
        end

        set_method :get_money_pledged, reuse: true do |doc|
          money_string(get_string(doc.css(".sidebar h3.num")))
        end

        set_method :get_money_goal do |doc|
          if doc.css(".sidebar .project-notice strong").empty?
            get_money_pledged(doc).to_i / get_percentage(doc).to_i * 100
          else
            money_string(get_string(doc.css(".sidebar .project-notice strong:nth-child(2)")))
          end
        end

        set_method :get_backer_count do |doc|
          doc.css("span.counter")[1].text
        end

        set_method :get_last_time do |doc|
          money_string(get_string(doc.css(".sidebar .row-fluid .span6:nth-child(2) h3.num")))
        end

        set_method :get_status do |last_time|
          if last_time.match("前") || last_time.match("達成")
            "finished"
          elsif last_time.match("開始")
            "preparing"
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
        set_method :get_currency_string do |result|
          "twd"
        end

        set_method :get_percentage, reuse: true do |doc|
          money_string(get_string(doc.css(".sidebar .row-fluid .span6:nth-child(1) h3.num")))
        end
      end
    end
  end
end