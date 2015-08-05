class DialogaPluginMyprofileController < MyProfileController

#  before_filter :check_permission
#  protect 'edit_profile', :profile, :only => [:set_home_page]


  def send_report
#    Dir
    path = File.join(Rails.root, 'script','sent_proposal_report')
    out = IO.popen(path)
     raise out.readlines.inspect
#profile.name
#render :text => 'bli'
#    report = params[:report] || 
#    @article.comment_paragraph_plugin_activate = !@article.comment_paragraph_plugin_activate
#    @article.save!
#    redirect_to @article.view_url
  end

  protected

#  def check_permission
#    @article = profile.articles.find(params[:id])
#    render_access_denied unless @article.comment_paragraph_plugin_enabled? && @article.allow_edit?(user)
#  end

end
