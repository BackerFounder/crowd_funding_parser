module CrowdFundingParser
  module Parser
    class Hereo < General
      def initialize
        @platform_url = "http://www.hereo.cc/"
        @item_css_class = ".project-list ul li"
        @status_css_class = ".projectImg .info .inner .detail span:nth-child(1)"
      end

      def get_lists
        [HTTParty.get(@platform_url + "/project-list.php", verify: false)]
      end

      def get_id(project_url)
        project_url.split("pid=").last
      end

      MethodBuilder.set_methods do
        insert_parser "Hereo"

        set_variable do
          @platform_url = "http://www.hereo.cc/"
        end

        set_method :get_title do |doc|
          get_string(doc.css(".container .text h3"))
        end

        set_method :get_category do |doc|
          get_string(doc.css(".contentMain .projectTag"))
        end

        set_method :get_creator_name do |doc|
          get_string(doc.css(".user-info .user .name h4 a"))
        end

        set_method :get_creator_id do |doc|
          doc.css(".user-info .user .name h4 a")[0]["href"].match(/mid=(\d+)/)[1]
        end

        set_method :get_creator_link do |doc|
          @platform_url + doc.css(".user-info .user .name h4 a")[0]["href"]
        end

        set_method :get_summary do |doc|
          doc.css(".container div.text").first.text.gsub(/\s/, "")
        end

        set_method :get_start_date do |doc|
        end

        set_method :get_end_date do |doc|
          doc.css(".projectInfo .detail .inner p").text.match(/\d{4}\/\d{2}\/\d{2}/).to_s
        end

        set_method :get_region do |doc|
          "Taiwan"
        end

        set_method :get_money_pledged do |doc|
          money_string(doc.css(".projectInfo .funded .inner .number strong").text.match(/[0-9,]+/).to_s)
        end

        set_method :get_money_goal do |doc|
          money_string(get_string(doc.css(".sidebar h3.num")))
        end

        set_method :get_backer_count do |doc|
          doc.css(".projectInfo .table .numberOfPeople .inner strong").text
        end

        set_method :get_left_time do |doc|
          raw_string = doc.css(".projectInfo .table .time .inner").text.gsub(/\s/, "")
          match_data = raw_string.match(/(\d+).*(天|小時)/)
          match_data[1] + match_data[2]
        end

        set_method :get_status do |left_time|
          if left_time.match("集資中")
            "online"
          elsif left_time.match("結束") || left_time.match("成功") || left_time.match(/\d+/).to_s == "0"
            "finished"
          else
            "online"
          end
        end

        set_method :get_following_count do
          doc.css("strong#track-count").text
        end

        set_method :get_currency_string do |result|
          "twd"
        end
      end
    end
  end
end

