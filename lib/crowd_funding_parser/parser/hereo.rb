require 'httparty'

module CrowdFundingParser
  module Parser
    class Hereo < General
      include HTTParty

      def platform_url
        "http://www.hereo.cc/"
      end

      def get_lists
        [HTTParty.get(platform_url + "/project-list.php")]
      end

      def item_css_class
        ".project-list ul li"
      end

      def status_css_class
        ".projectImg .info .inner .detail span:nth-child(1)"
      end

      # Project Info

      def get_title(doc)
        get_string(doc.css(".container .text h3"))
      end

      def get_category(doc)
        get_string(doc.css(".contentMain .projectTag"))
      end

      def get_creator_name(doc)
        get_string(doc.css(".user-info .user .name h4 a"))
      end

      def get_creator_id(doc)
        doc.css(".user-info .user .name h4 a")[0]["href"].match(/mid=(\d+)/)[1]
      end

      def get_creator_link(doc)
        platform_url + doc.css(".user-info .user .name h4 a")[0]["href"]
      end

      def get_summary(doc)
        doc.css(".container div.text").first.text.gsub(/\s/, "")
      end

      def get_start_date(doc)

      end

      def get_end_date(doc)
        doc.css(".projectInfo .detail .inner p").text.match(/\d{4}\/\d{2}\/\d{2}/).to_s
      end

      def get_region(doc)
        "Taiwan"
      end

      # for tracking

      def get_money_goal(doc)
        money_string(doc.css(".projectInfo .detail .inner p").text.match(/\$[0-9,]+/).to_s)
      end

      def get_money_pledged(doc)
        money_string(doc.css(".projectInfo .funded .inner .number strong").text.match(/[0-9,]+/).to_s)
      end

      def get_backer_count(doc)
        doc.css(".projectInfo .table .numberOfPeople .inner strong").text
      end

      def get_last_time(doc)
        raw_string = doc.css(".projectInfo .table .time .inner").text.gsub(/\s/, "")
        match_data = raw_string.match(/(\d+).*(天|小時)/)
        match_data[1] + match_data[2]
      end

      def get_status(last_time)
        if last_time.match("集資中")
          "online"
        elsif last_time.match("結束") || last_time.match("成功") || last_time.match(/\d+/).to_s == "0"
          "finished"
        else
          "online"
        end
      end

      def get_fb_count(doc)
        ""
      end

      def get_id(project_url)
        project_url.split("pid=").last
      end

      def get_following_count(doc)
        doc.css("strong#track-count").text
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