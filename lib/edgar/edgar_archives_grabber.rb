module EdgarArchivesGrabber

  require 'nokogiri'
  require 'open-uri'

  MAXIMUM_RETRIES = 5

  def self.get_monthly_archive_list
    limiter = 0
    begin
      limiter += 1
      url = "http://www.sec.gov/Archives/edgar/monthly/"
      doc = Nokogiri::HTML(open(URI.encode(url))) do |config|
        config.recover.noblanks
      end
    rescue
      if limiter < MAXIMUM_RETRIES
        retry
      else
        doc = nil
      end
    end
    unless doc.blank?
      file_names = doc.xpath('//td//a').collect {|a| a.attributes["href"].value }
      file_names.shift
      url_a = []
      file_names.each do |file_name|
        url_a << url + file_name
      end
      url_a.sort!
    end
    return url_a
  end
end