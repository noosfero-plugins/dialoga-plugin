# encoding: UTF-8
class DialogaPluginMyprofileController < MyProfileController

  before_filter :is_admin

  def send_report
    Delayed::Job.enqueue(DialogaPlugin::ReportJob.new(profile.id))
    Delayed::Job.enqueue(DialogaPlugin::RankingJob.new(profile.id))
    Delayed::Job.enqueue(DialogaPlugin::EventJob.new(profile.id))
    session[:notice] = _("Favor aguardar: o relatório será criado na pasta Relatorios")
    redirect_to :back
  end

  protected

  def is_admin
    render_access_denied unless current_person.is_admin?
  end


end
