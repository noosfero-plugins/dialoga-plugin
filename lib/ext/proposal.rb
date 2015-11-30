require_relative '../../../proposals_discussion/lib/proposals_discussion_plugin/proposal.rb'

class ProposalsDiscussionPlugin::Proposal < TinyMceArticle
  validate :abstract_max_length

  def abstract_max_length
    if abstract.size > 200 and environment.plugin_enabled? "Dialoga"
      errors.add(:proposal, "Proposal must be no longer than 200 characters")
    end
  end
end
