module SiteHelper
  def history(site)
    writings = Writing.find(:all, :conditions => ["TEXT_F_SITE = ?", site.id], :limit => 10, 
                            :order => 'TEXT_MODIFYTIME DESC')
    render_partial 'partials/history', :writings => writings
    # return debug writings
  end
end
