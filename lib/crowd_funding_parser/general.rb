module CrowdFundTracker
  module Parser
    class General
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

      def tracking(rel_url)
        project_url = @url + rel_url
        doc = get_doc_through_url(project_url)
        # get doc

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

      def project(rel_url)
        project_url = @url + rel_url
        doc = get_doc_through_url(project_url)
        # get doc

        project                  = Hash.new
        project['platform_project_id']    = get_id(rel_url)
        project['title']         = get_title(doc)
        project['url']           = project_url
        project['summary']       = get_summary(doc)
        project['category']      = get_category(doc)
        project['creator_name']  = get_creator_name(doc)
        project['creator_id']    = get_creator_id(doc)
        project['creator_link']  = get_creator_link(doc)
        project
      end

      def get(count = 10000)
        # needs @target and @item_css_class to get data
        doc = Nokogiri::HTML(@target)

        online_projects = doc.css(@item_css_class)
        limit = (count >= online_projects.count ? online_projects.count : count)

        # online_projects.first(limit).map do |project|
        Parallel.map(online_projects.first(limit), in_processes: 3, in_threads: 5) do |project|
          link_nodes = project.css("a:nth-child(1)")
          link = link_nodes.first["href"]
          result = project(link)
        end
      end

      def get_log(url)
        url.gsub!("#{@url}", "")
        tracking(url)
      end

      def get_doc_through_url(url)
        project_html = open(url)
        Nokogiri::HTML(project_html)
      end
    end
  end
end