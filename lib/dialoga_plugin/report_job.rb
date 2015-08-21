require 'csv'
class DialogaPlugin::ReportJob < Struct.new(:profile_id, :report_path)

  include ActionDispatch::TestProcess

  def self.create_report_path(profile, report_path)
    root_report_folder = profile.folders.where(:slug => 'relatorios').first
    root_report_folder ||= Folder.create!(:profile => profile, :name => 'Relatorios')
    FileUtils.mkdir_p "/tmp/#{report_path}"
    report_folder = Folder.find_by_slug(report_path)
    report_folder ||= Folder.create!(:profile => profile, :name => report_path, :parent => root_report_folder)
  end

  def upload_file(filepath, profile, report_folder)
    UploadedFile.create!(:uploaded_data => fixture_file_upload(filepath, 'text/csv'), :profile => profile, :parent => report_folder)
  end

  def compress_files(filename, pattern)
    filepath = "/tmp/#{report_path}/#{filename}.zip"
    system("cd /tmp/#{report_path} && zip #{filepath} #{pattern}")
    filepath
  end

  def perform
    profile = Profile.find(profile_id)
    report_folder = DialogaPlugin::ReportJob.create_report_path(profile, report_path)
    create_proposals_report(profile, report_folder)
  end

  def create_proposals_report(profile, report_folder)
    filepath = "/tmp/#{report_path}/propostas.csv"

    CSV.open(filepath, 'w' ) do |csv|
      tasks = ProposalsDiscussionPlugin::ProposalTask.all
      count = 0
      csv << ['Origem', 'Status', 'Criada em', 'Moderado por', 'Data de Moderado', 'Validado por', 'Data de Validado', 'Autor', 'Proposta', 'Categorias']
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
        info.push(task.proposal_evaluation.present? && task.proposal_evaluation.evaluated_by.present? ? task.proposal_evaluation.evaluated_by.name : '')
        info.push(task.proposal_evaluation.present? ? task.proposal_evaluation.created_at.strftime("%d/%m/%y %H:%M") : '')
        info.push(task.closed_by.present? ? task.closed_by.name : '')
        info.push(task.closed_by.present? ? task.end_date.strftime("%d/%m/%y %H:%M") : '')
        info.push(task.requestor.present? ? task.requestor.name : '')
        info.push(task.abstract.present? ? task.abstract.gsub(/\s+/, ' ').strip : '')
        info.push(task.categories.map {|c| c.name}.join(' '))
        csv << info
      end
    end
    upload_file(filepath, profile, report_folder)
  end

end
