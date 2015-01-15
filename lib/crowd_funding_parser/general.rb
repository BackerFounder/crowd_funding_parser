module CrowdFundingParser
  module Parser
    class General
      def parse_tracking_data(doc, project_url)
        project = Hash.new
        project['money_goal']      = get_money_goal(doc).to_i
        project['money_pledged']   = get_money_pledged(doc).to_i
        project['backer_count']    = get_backer_count(doc).to_i
        project['last_time']       = get_last_time(doc)
        project['status']          = get_status(project['last_time'])
        # project['backer_list']     = get_backer_list(project_url)
        project['fb_count']        = get_fb_count(doc).to_i
        project['following_count'] = get_following_count(doc).to_i
        project
      end

      def parse_content_data(doc, project_url)
        project                  = Hash.new
        project['platform_project_id'] = get_id(project_url)
        project['title']         = get_title(doc)
        project['url']           = project_url
        project['summary']       = get_summary(doc)
        project['category']      = get_category(doc)
        project['creator_name']  = get_creator_name(doc)
        project['creator_id']    = get_creator_id(doc)
        project['creator_link']  = get_creator_link(doc)
        project
      end

      def get_project_links(required_status = "online")
        links = []
        
        @targets.each do |target|
          doc = Nokogiri::HTML(target)
          online_projects = doc.css(@item_css_class)

          Parallel.map(online_projects, in_processes: 2 , in_threads: 4) do |project|
            link_nodes = project.css("a:nth-child(1)")
            status = get_status(get_string(project.css(@status_css_class)))
            link = link_nodes.first["href"]
            if status == "finished" && required_status == "finished"
              links << link
            elsif status == "online" && required_status == "online"
              links << link  
            elsif status == "preparing" && required_status == "preparing"
              links << link
            end
          end
        end

        links
      end

      def get_doc_through_url(project_url)
        project_html = open(project_url)
        Nokogiri::HTML(project_html)
      end

      private

      def get_id(project_url)
        rel_url = get_rel_url(project_url)
        rel_url.split("/").last
      end

      def get_rel_url(url)
        url.gsub("#{@url}", "")
      end

      def get_string(elements)
        elements.first.text.strip
      end

      def money_string(money)
        money.sub('$', '').sub(',', '').sub('NT', "")
      end

      def convert_time(left_time)
        days = ((left_time / (60 * 60 * 24))).to_i
        hours = ((left_time / (60 * 60)) % 24).to_i
        minutes = ((left_time / 60) % 60).to_i
        "#{days}天#{hours}小時#{minutes}分鐘"
      end

    end
  end
end