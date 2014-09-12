class EdgarArchivesController < ApplicationController

  def monthly_archive_list
    @url_a = EdgarArchivesGrabber.get_monthly_archive_list
  end

end
