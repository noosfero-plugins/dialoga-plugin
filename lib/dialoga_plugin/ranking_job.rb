# encoding: UTF-8
require 'csv'
class DialogaPlugin::RankingJob < DialogaPlugin::ReportJob

  def perform
    profile = Profile.find(profile_id)
    report_folder = create_report_path(profile)
    create_ranking_report(profile, report_folder)
  end

  def create_ranking_report(profile, report_folder)
    ProposalsDiscussionPlugin::Discussion.where(:profile_id => profile.id).map do |discussion|
      articles = discussion.topics
      articles.each do |article|
        puts "#{article.slug}"
        ranking = article.ranking
        next if ranking.empty?

        filepath = '/tmp/' + DateTime.now.strftime('%Y-%m-%d-%H-%m-%S') + '-' + "ranking_#{discussion.slug}_#{article.slug}.csv"
        CSV.open(filepath, 'w' ) do |csv|
          csv << ['Posição', 'Id', 'Proposta', 'Positivo', 'Negativo', 'Exibições', 'Valor']
          ranking.each_with_index {|r, i| csv << [i+1, r.values].flatten}
        end
        uploaded_file = UploadedFile.new(:uploaded_data => fixture_file_upload(filepath, 'text/csv'), :profile => profile, :parent => report_folder)
        uploaded_file.save
      end
    end
  end

end
