class DialogaPlugin::ReportJob < Struct.new(:profile_id)

  include ActionDispatch::TestProcess

  def create_report_path(profile)
    root_report_folder = profile.folders.where(:slug => 'relatorios').first
    root_report_folder ||= Folder.create!(:profile => profile, :name => 'Relatorios')

    report_folder = Folder.find_by_slug(DateTime.now.strftime('%Y-%m-%d'))

    report_folder ||= Folder.create!(:profile => profile, :name => DateTime.now.strftime('%Y-%m-%d'), :parent => root_report_folder)
  end

  def perform
    profile = Profile.find(profile_id)
    report_folder = create_report_path(profile)
    create_proposals_report(profile, report_folder)
  end

  def create_proposals_report(profile, report_folder)
    filepath = '/tmp/' + DateTime.now.strftime('%Y-%m-%d-%H-%m-%S') + '-' + 'propostas.csv'
    file = File.open(filepath, 'w+')

    tasks = ProposalsDiscussionPlugin::ProposalTask.all
    count = 0
    header = "'Origem';'Status';'Criada em';'Moderado por';'Data de Moderado';'Validado por';'Data de Validado';'Autor';'Proposta'\n"
    file.write(header)
    status_translation = {
      1 => 'Pendente de Moderacao',
      2 => 'Rejeitada',
      3 => 'Aprovada',
      5 => 'Pre Aprovada',
      6 => 'Pre Rejeitada',
    }
    tasks.map do |task|
      count += 1
      puts "%s de %s: adicionando task: %s" % [count, tasks.count, task.id ]
      info = []
      info.push(task.proposal_source)
      info.push(status_translation[task.status])
      info.push(task.created_at.strftime("%d/%m/%y %H:%M"))
      info.push(task.proposal_evaluation.present? ? task.proposal_evaluation.evaluated_by.name : '')
      info.push(task.proposal_evaluation.present? ? task.proposal_evaluation.created_at.strftime("%d/%m/%y %H:%M") : '')
      info.push(task.closed_by.present? ? task.closed_by.name : '')
      info.push(task.closed_by.present? ? task.end_date.strftime("%d/%m/%y %H:%M") : '')
      info.push(task.requestor.present? ? task.requestor.name : '')
      info.push(task.abstract.present? ? task.abstract.gsub(/\s+/, ' ').strip : '')
      file.write(info.map{|i| "'" + i.to_s + "'"}.join(";"))
      file.write("\n")
    end

    file.close

    uploaded_file = UploadedFile.new(:uploaded_data => fixture_file_upload(filepath, 'text/csv'), :profile => profile, :parent => report_folder)
    uploaded_file.save
  end

end
