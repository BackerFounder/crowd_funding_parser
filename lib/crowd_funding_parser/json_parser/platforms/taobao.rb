module CrowdFundingParser
  module JsonParser
    class Taobao
      def initialize
        # status: 成功 = 2, 募資中 = 1, 預熱中 = 3
        @json_url = "http://hstar-hi.alicdn.com/dream/ajax/getProjectList.htm?page=4&pageSize=20&projectType=&type=6&status=&sort=&callback=jsonp"
      end

      def get_total_urls(status = 1)
        page_count = get_total_page(status)
        total_urls = []
        page_count.times do |i|
          total_urls << get_workable_url(i + 1, status)
        end
        total_urls
      end

      def get_total_jsons(status = 1)
        urls = get_total_urls(status)
        jsons = []
        urls.each do |url|
          jsons << turn_url_to_json(url)
        end
      end

      def get_workable_url(page = 1, status = 1)
        "http://hstar-hi.alicdn.com/dream/ajax/getProjectList.htm?page=#{page}&pageSize=20&projectType=&type=6&status=#{status}"
      end

      def get_total_page(status = 1)
        url = "http://hstar-hi.alicdn.com/dream/ajax/getProjectList.htm?page=1&pageSize=20&projectType=&type=6&status=#{status}"
        json = turn_url_to_json(url)
        page_count = json["pageTotal"]
      end

      def turn_url_to_json(url)
        open_url = open(url)
        json = JSON.load(open_url)
      end
    end
  end
end