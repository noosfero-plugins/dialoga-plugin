# encoding: UTF-8
require 'csv'
class DialogaPlugin::RankingJob < DialogaPlugin::ReportJob

  def perform
    profile = Profile.find(profile_id)
    report_folder = DialogaPlugin::ReportJob.create_report_path(profile, report_path)
    create_ranking_report(profile, report_folder)
  end

  def create_ranking_report(profile, report_folder)
    ProposalsDiscussionPlugin::Discussion.where(:profile_id => profile.id).map do |discussion|
      articles = discussion.topics
      articles.each do |article|
        puts "#{article.slug}"
        ranking = article.ranking
        next if ranking.empty?

        filepath = "/tmp/#{report_path}/ranking-#{discussion.slug}_#{article.slug}.csv"
        CSV.open(filepath, 'w', {:col_sep => ';', :force_quotes => true}) do |csv|
          csv << ['Posição', 'Id', 'Proposta', 'Positivo', 'Negativo', 'Exibições', 'Valor', 'Autor', 'Email do Autor']
          ranking.each_with_index {|r, i| csv << [r.position, r.id, r.abstract, r.votes_for, r.votes_against, r.hits, r.effective_support, r.proposal.author.present? ? r.proposal.author.name : r.proposal.author_name, r.proposal.author.present? ? r.proposal.author.email : ''].flatten}
        end
      end
    end
    upload_file(compress_files('rankings', 'ranking-*'), profile, report_folder)
  end

end
