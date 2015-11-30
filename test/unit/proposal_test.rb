require_relative '../test_helper'

class ProposalTest < ActiveSupport::TestCase

  def setup
    @profile = fast_create(Community)
    @person = fast_create(Person)
    @discussion = ProposalsDiscussionPlugin::Discussion.create!(:name => 'discussion', :profile => person, :allow_topics => false)
    @proposal = ProposalsDiscussionPlugin::Proposal.new(:name => 'test', :abstract => 'abstract', :profile => @profile, :parent => @discussion)
    @proposal.created_by = @person
  end

  attr_reader :profile, :proposal, :person, :discussion

  should 'should not save a proposal with an abstract > 200 chars' do
    proposal.abstract = 201.times.map{'B'}.join
    refute proposal.valid?
    refute proposal.save
  end

  should 'should save a proposal with  abstract <= 200 chars' do
    proposal.abstract = 200.times.map{'B'}.join
    assert proposal.valid?
    assert proposal.save
  end


end
