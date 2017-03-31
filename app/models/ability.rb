class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new # guest user (not logged in)

    # TODO: currently checks if it has the class, in the future it will check
    # a `roles` attribute or similar

    # TODO: using `voter_id`, `artist_id` which will become `user_id` in future
    # after models are unified

    # TODO: why do admins not require activation?
    if user.is_a?(Admin)
      can :manage, :all
    end

    if user.is_a?(Artist) && user.activated?
      can :manage, GrantSubmission, artist_id: user.id
      can :manage, ArtistSurvey, artist_id: user.id
      can :manage, Proposal, grant_submission_id: user.grant_submission_ids
    end

    if user.is_a?(Voter) && user.activated?
      can :manage, VoterSurvey, voter_id: user.id
      can :manage, Vote, voter_id: user.id
      # TODO: should voters be able to change their 'GrantVoter`s?

      can :read, GrantSubmission
      can :read, VoterSubmissionAssignment, voter_id: user.id
    end
  end
end
