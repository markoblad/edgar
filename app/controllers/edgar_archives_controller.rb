class EdgarArchivesController < ApplicationController

  def monthly_archive_list
    monthly_archive_list = EdgarArchivesGrabber.get_monthly_archive_list
    @title = "Monthly List Archive"
    @obj_a = monthly_archive_list.map {|i| {name: i.split('/')[-1], url: i} }
    @link_path_sym = :edgar_archives_get_month_archive_path
  end

  def get_month_archive
    @title = "Monthly List Archive for #{params[:url].split('/')[-1]}"
    month_archive_hashes = EdgarArchivesGrabber.get_month_archive(params[:url])
    @obj_a = month_archive_hashes
    @link_path_sym = :edgar_archives_get_filing_file_list_path
    @source_url = params[:url]
    # render :monthly_archive_list
  end

  def get_filing_file_list
    @title = "File List for #{params[:url].split('/')[-1]}"
    xbrl_files_hashes = EdgarArchivesGrabber.get_filing(params[:source_url], params[:url])
    @obj_a = xbrl_files_hashes.map {|h| {url: h[:xbrl_file_url], name: h[:xbrl_file_description]} }
    @link_path_sym = nil
    @source_url = params[:url]
    @target = "_blank"
    # render :monthly_archive_list
  end

  def parse_file
    @title = "Parsed File for #{params[:url].split('/')[-1]}"
    @doc = EdgarArchivesGrabber.process_edgar_url(params[:url])
  end


end
