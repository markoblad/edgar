module EdgarFtp

  require 'net/ftp'

  # EdgarFtp.get_daily_index_text_file('edgar/daily-index/2013/QTR4', 'sitemap.20131120.xml', opts={})
  def self.get_daily_index_text_file(directory, file_name, opts={})
    options = {
      write_file_name_and_path: Rails.root.join('tmp', file_name)
    }.merge(opts)
    ftp = Net::FTP.new('ftp.sec.gov')
    ftp.login
    files = ftp.chdir(directory)
    ftp.gettextfile(file_name, options[:write_file_name_and_path])
  end
  # ftp://ftp.sec.gov/edgar/daily-index/

  # EdgarFtp.get_daily_index_bin_file('edgar/daily-index/2013/QTR4', 'company.20131120.idx.gz', opts={})
  def self.get_daily_index_bin_file(directory, file_name, opts={})
    options = {
      write_file_name_and_path: Rails.root.join('tmp', file_name),
      blocksize: 1024
    }.merge(opts)
    ftp = Net::FTP.new('ftp.sec.gov')
    ftp.login
    files = ftp.chdir(directory)
    ftp.getbinaryfile(file_name, options[:write_file_name_and_path], options[:blocksize])
  end
end