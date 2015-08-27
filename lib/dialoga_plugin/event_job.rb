# encoding: UTF-8
class DialogaPlugin::EventJob < DialogaPlugin::ReportJob

  def perform
    profile = Profile.find(profile_id)
    report_folder = DialogaPlugin::ReportJob.create_report_path(profile, report_path)
    create_event_report(profile, report_folder)
  end

  def create_event_report(profile, report_folder)
    events = Event.where(:profile_id => profile.id)
    events.map do |event|
      filepath = "/tmp/#{report_path}/evento-#{event.slug}.csv"
      count = 0
      CSV.open(filepath, 'w', {:col_sep => ';', :force_quotes => true} ) do |csv|
        csv << [event.name]
        csv << ['Nome', 'Email']
        event.person_followers.map do |person|
          count += 1
          puts "%s de %s: adicionando evento: %s" % [count, event.person_followers.count, event.id ]
          info = []
          info.push(person.name)
          info.push(person.email)
          csv << info
        end
      end
    end
    upload_file(compress_files('eventos', 'evento-*'), profile, report_folder)
  end

end
