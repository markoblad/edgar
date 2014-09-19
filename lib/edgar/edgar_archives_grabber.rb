module EdgarArchivesGrabber

  require 'nokogiri'
  require 'open-uri'

  MAXIMUM_RETRIES = 5
  CONTROL_FILE_PATH = Rails.root.join("config", "control.txt")

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
      get_monthly_archive_list = []
      file_names.each do |file_name|
        get_monthly_archive_list << url + file_name
      end
      get_monthly_archive_list.sort!
    end
    return get_monthly_archive_list
  end

  def self.get_month_archive(url)
    filings, source_last_build_date, source_pub_date = get_filings(url)
    month_archive_hashes = []
    filings.each do |filing|
      xbrl_files_zip_url = get_xbrl_files_zip_url(filing)
      title = begin filing.css('/title').text.strip || "" rescue "" end
      month_archive_hashes << {name: title, url: xbrl_files_zip_url}
    end
    return month_archive_hashes
  end

  def self.get_filings(url)
    limiter = 0
    begin
      limiter += 1
      doc = Nokogiri::XML(open(URI.encode(url))) do |config|
        config.recover.noblanks
      end
      doc.remove_namespaces!
    rescue
      if limiter < MAXIMUM_RETRIES
        retry
      else
        doc = nil
      end
    end
    return nil if doc.blank?
    source_last_build_date = begin doc.document.xpath('//rss/channel/lastBuildDate').text.strip || "" rescue "" end
    source_pub_date = begin doc.document.xpath('//rss/channel/pubDate').text.strip || "" rescue "" end

    filings = begin doc.document.xpath('//rss/channel/item') || [] rescue [] end
    xbrl_files_zip_urls_to_exclude = []
    return filings, source_last_build_date, source_pub_date
  end

  def self.get_xbrl_files_zip_url(filing)
    encl = begin filing.css('/enclosure') rescue "" end
    unless encl.blank?
      xbrl_files_zip_url = get_edgar_attribute(encl, "url")
    else
      xbrl_files_zip_url = begin filing.css('/link').text.strip || "" rescue "" end
    end
    return xbrl_files_zip_url
  end

  def self.get_filing(month_url, xbrl_files_zip_url)
    filings, source_last_build_date, source_pub_date = get_filings(month_url)
    filing = filings.detect {|f| get_xbrl_files_zip_url(f) == xbrl_files_zip_url}
    xbrl_files_hashes = process_filing(month_url, filing, source_last_build_date, source_pub_date, [])
  end

  def self.process_filing(url, filing, source_last_build_date, source_pub_date, xbrl_files_zip_urls_to_exclude)
    xbrl_files_zip_url = get_xbrl_files_zip_url(filing)
# debugger
    return nil if xbrl_files_zip_urls_to_exclude.include?(xbrl_files_zip_url)
    title = begin filing.css('/title').text.strip || "" rescue "" end
    xbrl_files_description = begin filing.css('/description').text.strip || "" rescue "" end
    xbrl_files_pub_date = begin filing.css('/pubDate').text.strip || "" rescue "" end
    company_name = begin filing.css('/xbrlFiling/companyName').text.strip || "" rescue "" end
    cik = begin filing.css('/xbrlFiling/cikNumber').text.strip || "" rescue "" end
    xbrl_files_form_type = begin filing.css('/xbrlFiling/formType').text.strip || "" rescue "" end
    xbrl_files_filing_date = begin filing.css('/xbrlFiling/filingDate').text.strip || "" rescue "" end
    xbrl_files_accession_number = begin filing.css('/xbrlFiling/accessionNumber').text.strip || "" rescue "" end
    xbrl_files_file_number = begin filing.css('/xbrlFiling/fileNumber').text.strip || "" rescue "" end
    xbrl_files_acceptance_datetime = begin filing.css('/xbrlFiling/acceptanceDatetime').text.strip || "" rescue "" end
    xbrl_files_period = begin filing.css('/xbrlFiling/period').text.strip || "" rescue "" end
    xbrl_files_assistant_director = begin filing.css('/xbrlFiling/assistantDirector').text.strip || "" rescue "" end
    assigned_sic = begin filing.css('/xbrlFiling/assignedSic').text.strip || "" rescue "" end
    xbrl_files_fiscal_year_end = begin filing.css('/xbrlFiling/fiscalYearEnd').text.strip || "" rescue "" end

    xbrl_files_hashes = []
    xbrl_files = begin filing.css('/xbrlFiling/xbrlFiles/xbrlFile') || [] rescue [] end
    xbrl_files.each do |file|
      xbrl_file_sequence = get_edgar_attribute(file, "sequence")
      xbrl_file_type = get_edgar_attribute(file, "type")
      xbrl_file_size = get_edgar_attribute(file, "size")
      xbrl_file_description = get_edgar_attribute(file, "description")
      xbrl_file_url = get_edgar_attribute(file, "url")
      xbrl_h = {}
      xbrl_h = {
        source_url: url,
        source_last_build_date: begin DateTime.parse(source_last_build_date) rescue nil end,
        source_pub_date: begin DateTime.parse(source_pub_date) rescue nil end,
        title: title,
        xbrl_files_zip_url: xbrl_files_zip_url,
        xbrl_files_description: xbrl_files_description,
        xbrl_files_pub_date: begin DateTime.parse(xbrl_files_pub_date) rescue nil end,
        company_name: company_name,
        cik: cik,
        xbrl_files_form_type: xbrl_files_form_type,
        xbrl_files_filing_date: begin Date.strptime(xbrl_files_filing_date, '%m/%d/%Y') rescue nil end,
        xbrl_files_accession_number: xbrl_files_accession_number,
        xbrl_files_file_number: xbrl_files_file_number,
        xbrl_files_acceptance_datetime: begin DateTime.parse(xbrl_files_acceptance_datetime) rescue nil end,
        xbrl_files_period: begin Date.parse(xbrl_files_period) rescue nil end, 
        xbrl_files_assistant_director: xbrl_files_assistant_director,
        assigned_sic: assigned_sic,
        xbrl_files_fiscal_year_end: xbrl_files_fiscal_year_end,
        xbrl_file_sequence: xbrl_file_sequence,
        xbrl_file_type: xbrl_file_type,
        xbrl_file_size: xbrl_file_size,
        xbrl_file_description: xbrl_file_description,
        xbrl_file_url: xbrl_file_url
      }

      xbrl_files_hashes << xbrl_h
    end
    puts DateTime.now.utc.to_s + " - EdgarArchivesGrabber::process_filing - Finished parsing and insertion into database xbrl_files with zip url of #{xbrl_files_zip_url} and description of #{xbrl_files_description}."
    return xbrl_files_hashes
  end

  def self.get_edgar_attribute(element, att)
    begin return_att = element.attributes[att].value || "" rescue "" end
    if return_att.blank?
      begin return_att = element.attribute(att).value || "" rescue "" end
    end
    return return_att
  end

  def self.process_edgar_url(url)
    limiter = 0
    begin
      limiter += 1
      doc = Nokogiri::XML(open(URI.encode(url))) {|config| config.recover.nonet}
    rescue Exception => e
      if limiter < MAXIMUM_RETRIES
        retry
      else
        doc = nil
        str = "Failure in EdgarFileGrabber::process_____file to parse doc using Nokogiri::XML for url #{url}."
        puts DateTime.now.utc.to_s + " - " + str
       end
    end
    begin
      ns_href = doc.root.namespace.href
    rescue
      ns_href = ""
    end
    begin
      ns_prefix = doc.root.namespace.prefix
    rescue
      ns_prefix = ""
    end
    return doc, ns_href, ns_prefix
  end
end