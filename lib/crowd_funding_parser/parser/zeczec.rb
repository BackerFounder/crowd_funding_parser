require 'open-uri'

module CrowdFundingParser
  module Parser
    class Zeczec < General
      def initialize
        @url = "https://www.zeczec.com"
        @targets = [open(@url + "/categories")]
        @item_css_class = ".project-list .span4"
        @status_css_class = ".meta span:nth-child(2)"
      end

      def get_id(rel_url)
        rel_url.split("/").last
      end

      def get_title(doc)
        get_string(doc.css("a.project-title"))
      end

      def get_category(doc)
        doc.css(".project-meta").css("a")[0].text
      end

      def get_creator_name(doc)
        doc.css(".project-meta").css("a")[1].text.strip
      end

      def get_creator_id(doc)
        doc.css(".project-meta").css("a")[1]["href"].split("/").last
      end

      def get_creator_link(doc)
        @url + doc.css(".creator .fly-center a").first["href"]
      end

      def get_summary(doc)
        doc.css(".project-content").first.text.to_s[0..500].strip
      end

      # for tracking

      def get_money_goal(doc)
        if doc.css(".sidebar .project-notice strong").empty?
          get_money_pledged(doc).to_i / get_percentage(doc).to_i * 100
        else
          money_string(get_string(doc.css(".sidebar .project-notice strong:nth-child(2)")))
        end
      end

      def get_money_pledged(doc)
        money_string(get_string(doc.css(".sidebar h3.num")))
      end

      def get_backer_count(doc)
        get_string(doc.css("span.counter"))
      end

      def get_last_time(doc)
        money_string(get_string(doc.css(".sidebar .row-fluid .span6:nth-child(2) h3.num")))
      end

      def get_percentage(doc)
        money_string(get_string(doc.css(".sidebar .row-fluid .span6:nth-child(1) h3.num")))
      end

      def get_status(last_time)
        if last_time.match("前") || last_time.match("達成")
          "finished"
        elsif last_time.match("開始")
          "preparing"
        else
          "online"
        end
      end

      def get_fb_count(doc)
        ""
      end

      def get_following_count(doc)
        ""
      end

      def get_backer_list(project_url)
        []
      end
    end
  end
end