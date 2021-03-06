require "json"
require 'open-uri'
require "iconv"

module CrowdFundingParser
  module Parser
    class An9 < General
      def initialize
        @url = "http://www.an9.com.tw/Dream/"
        @status_css_class = ".sideCon>a"
      end

      def get_main_categories(add_categories)
        add_categories.select { |c| c[:parent_id].nil? }
      end

      def get_project_links(required_status = "online")
        links = []
        error_count = 0
        not_found_count = 0
        Parallel.each(1..100000, in_precesses: 2, in_threads: 5, progress: "Get #{self} links") do |i|
          begin
            link = @url + i.to_s
            project = get_doc_through_url(link)
            not_found_message = project.css(".actMsg p")
            if not_found_message.present? && get_string(not_found_message).match(/不存在/)
              not_found_count += 1
            else
              status = get_status(get_string(project.css(@status_css_class)))

              if status == required_status
                links << link
              end
              not_found_count = 0
              error_count = 0
            end
          rescue Exception => e
            error_count += 1
            raise Parallel::Break if not_found_count >= 50 || error_count >= 50
          end
        end

        links
      end

      private

      def get_title(result)
        if @parse_method == :doc
          get_string(result.css(".NS_projects__header h2 .green-dark"))
        else
          result["name"]
        end
      end

      def get_category(result)
        if @parse_method == :doc
          get_string(result.css(".container-flex .h5 a.grey-dark:nth-child(2) b"))
        else
          result["category"]["name"]
        end
      end

      def get_creator_name(result)
        if @parse_method == :doc
          get_string(result.css(".NS_projects__creator .col-8>h5 a.remote_modal_dialog"))
        else
          result["creator"]["name"]
        end
      end

      def get_creator_id(result)
        if @parse_method == :doc
          creator_link = result.css(".NS_projects__creator .col-8>h5 a.remote_modal_dialog").first["href"]
          creator_link.split("/")[-3]
        else
          result["creator"]["id"]
        end
      end

      def get_creator_link(result)
        if @parse_method == :doc
          creator_link = @url + result.css(".NS_projects__creator .col-8>h5 a.remote_modal_dialog").first["href"]
        else
          result["creator"]["urls"]["web"]["user"]
        end
      end

      def get_summary(result)
        if @parse_method == :doc
          get_string(result.css(".container-flex .col-8 .mobile-hide p.h3.mb3"))
        else
          result["blurb"]
        end
      end

      def get_start_date(result)
        if @parse_method == :doc
          # no start date on page
        else
          Time.at(result["launched_at"])
        end
      end

      def get_end_date(result)
        if @parse_method == :doc
          result.css(".NS_projects__deadline_copy p.grey-dark time[datetime]")[0]["datetime"]
        else
          time = Time.at(result["deadline"])
        end
      end

      def get_region(result)
        if @parse_method == :doc
          get_string(result.css(".container-flex .h5 a.grey-dark:nth-child(1) b"))
        else
          result["location"]["displayable_name"]
        end
      end

      # for tracking

      def get_money_goal(result)
        if @parse_method == :doc
          result.css("div[data-pledged]").first["data-goal"]
        else
          result["goal"]
        end
      end

      def get_money_pledged(result)
        if @parse_method == :doc
          result.css("div[data-pledged]").first["data-pledged"]
        else
          result["pledged"]
        end
      end

      def get_backer_count(result)
        if @parse_method == :doc
          result.css("div[data-backers-count]").first["data-backers-count"]
        else
          result["backers_count"]
        end
      end

      def get_left_time(result)
        if @parse_method == :doc
          end_date = result.css("div[data-end_time]").first["data-end_time"]
          last_seconds = Time.parse(end_date) - Time.now
        else
          last_seconds = result["deadline"].to_i - Time.now.to_i
        end
        last_day = last_seconds.to_i / 86400
        if last_day <= 0
          "已結束"
        else
          last_day.to_s + "天"
        end
      end

      def get_status(button_text)
        case button_text
        when /贊助/
          "online"
        when /喜歡/
          "voting"
        when /結束|成功/
          "finished"
        else
          "online"
        end
      end

      def get_fb_count(result)
        
      end

      def get_following_count(result)
        
      end

      def get_backer_list(project_url)
        []
      end

      def get_currency_string(result)
        if @parse_method == :doc
          result.css("data[data-currency]")[0]["data-currency"]
        else
          result["currency"]
        end
      end
    end
  end
end