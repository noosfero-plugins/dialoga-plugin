# encoding: UTF-8
class DialogaPlugin::EventJob < DialogaPlugin::ReportJob

  def perform
    profile = Profile.find(profile_id)
    report_folder = create_report_path(profile)
    create_event_report(profile, report_folder)
  end

  def create_event_report(profile, report_folder)
    events = Event.where(:profile_id => profile.id)
    events.map do |event|
      filepath = '/tmp/' + DateTime.now.strftime('%Y-%m-%d-%H-%m-%S') + '-' + event.slug
      file = File.open(File.join(filepath), 'w+')
      file.write(event.name+ "\n")
      header = "'Nome';'Email'\n"
      file.write(header)
      count = 0
      event.person_followers.map do |person|
        count += 1
        puts "%s de %s: adicionando evento: %s" % [count, event.person_followers.count, event.id ]
        info = []
        info.push(person.name)
        info.push(person.email)
        file.write(info.map{|i| "'" + i.to_s + "'"}.join(";"))
        file.write("\n")
      end
      file.close
      uploaded_file = UploadedFile.new(:uploaded_data => fixture_file_upload(filepath, 'text/csv'), :profile => profile, :parent => report_folder)
      uploaded_file.save
    end
  end

end
