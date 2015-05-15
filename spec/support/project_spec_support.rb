module ProjectSpecSupport
 def get_project_doc(project_url, platform_name)
   VCR.use_cassette(platform_name, re_record_interval: 3.days, record: :new_episodes) do
     response = HTTParty.get(project_url)
     Nokogiri::HTML(response)
   end
 end

 def get_month_distance(date1)
  date2 = Time.now
  (date2.year * 12 + date2.month) - (date1.year * 12 + date1.month)
 end
end
