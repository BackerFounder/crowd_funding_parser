module CrowdFundingParser
  module Parser
    class Zeczec < General

      def initialize
        @platform_url = "https://www.zeczec.com"
        @item_css_class = ".project-list .span4"
        @status_css_class = ".meta span:nth-child(2)"
      end

      def get_lists
        [HTTParty.get(@platform_url + "/categories", verify: false)]
      end

      MethodBuilder.set_methods do
        insert_parser "Zeczec"

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

        set_method :get_money_pledged do |doc|
          money_string(get_string(doc.css(".sidebar h3.num"))).to_s
        end

        set_method :get_percentage do |doc|
          get_string(doc.css(".sidebar .row-fluid .span6 .js-percentage-raised")).to_f
        end

        set_method :get_money_goal do |doc|
          money_pledged = @parser.get_money_pledged(doc).to_i
          percentage = @parser.get_percentage(doc)/100
          (money_pledged / percentage).to_i.to_s
        end

        set_method :get_backer_count do |doc|
          link_regex = /projects\/.+\/backers/
          backer_count_tab = doc.css(".project-menu .nav-tabs a").map do |tab|
            tab if tab["href"].match(link_regex)
          end.compact[0]
          backer_count_tab.css("span").text
        end

        set_method :get_left_time do |doc|
          money_string(get_string(doc.css(".sidebar .row-fluid .span6:nth-child(2) h3.num")))
        end

        set_method :get_status do |left_time|
          if left_time.match("前") || left_time.match("達成")
            "finished"
          elsif left_time.match("開始")
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
      end
    end
  end
end
