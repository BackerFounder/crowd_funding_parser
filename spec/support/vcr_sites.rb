module VcrSites
 def get_project_doc(project_url, platform_name)
   VCR.use_cassette(platform_name, re_record_interval: 3.days) do
     response = HTTParty.get(project_url)
     Nokogiri::HTML(response)
   end
 end
end
