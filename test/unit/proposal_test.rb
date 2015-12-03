require_relative '../test_helper'

class ProposalTest < ActiveSupport::TestCase

  def setup
    @profile = fast_create(Community)
    @person = fast_create(Person)
    @discussion = ProposalsDiscussionPlugin::Discussion.create!(:name => 'discussion', :profile => person, :allow_topics => false)
    @proposal = ProposalsDiscussionPlugin::Proposal.new(:name => 'test', :abstract => 'abstract', :profile => @profile, :parent => @discussion)
    @proposal.created_by = @person
    @environment = Environment.default
    environment.enable_plugin(DialogaPlugin)
  end

  attr_reader :profile, :proposal, :person, :discussion, :environment

  should 'should not save a proposal with an abstract greater than 200 chars' do
    proposal.abstract = 201.times.map{'B'}.join
    refute proposal.valid?
    refute proposal.save
    assert proposal.errors[:abstract].present?
  end

  should 'should save a proposal with an abstract greater than 200 chars and dialoga plugin is not enabled' do
    environment.disable_plugin(DialogaPlugin)
    proposal.abstract = 201.times.map{'B'}.join
    assert proposal.valid?
    assert proposal.save
  end

  should 'should save a proposal with an abstract not greater than 200 chars' do
    proposal.abstract = 200.times.map{'B'}.join
    assert proposal.valid?
    assert proposal.save
  end


end
