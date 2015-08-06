class DialogaPluginMyprofileController < MyProfileController

  protect 'perform_task', :profile

  def send_report
    path = File.join(Rails.root,'plugins','dialoga','script')
    scripts = ['sent_event_report', 'sent_proposal_report']
    scripts.map do |script|
      cmd = File.join(path,script) + ' ' + current_person.email.to_s
      fork {IO.popen(cmd).read}
    end
    session[:notice] = _("The report wil be sent to email #{current_person.email}")
    redirect_to :back
  end

end
