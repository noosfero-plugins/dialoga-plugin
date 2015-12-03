require_relative '../../../proposals_discussion/lib/proposals_discussion_plugin/proposal.rb'

class ProposalsDiscussionPlugin::Proposal

  validates :abstract, length: {maximum: 200}, if: proc { |a| a.environment.plugin_enabled?(DialogaPlugin)}

end
