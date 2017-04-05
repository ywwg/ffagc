class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= nil

    # TODO: currently checks if it has the class, in the future it will check
    # a `roles` attribute or similar

    # TODO: using `voter_id`, `artist_id` which will become `user_id` in future
    # after models are unified

    # TODO: why do admins not require activation?

    # Allow an initial Admin to be crated by anyone
    can :manage, Admin unless Admin.exists?

    can [:new, :create], Artist
    can [:new, :create], Voter
    can [:new], GrantSubmission

    can :read, Grant, hidden: false

    if user.is_a?(Admin)
      can :manage, :all

      cannot :vote, GrantSubmission
    end

    if user.is_a?(Artist)
      can :manage, Artist, id: user.id
      can :manage, ArtistSurvey, artist_id: user.id

      cannot :index, [Artist, ArtistSurvey]

      if  user.activated?
        can [:manage, :discuss, :edit_answers], GrantSubmission, artist_id: user.id
        can :manage, Proposal, grant_submission_id: user.grant_submission_ids

        cannot [:vote, :edit_questions], GrantSubmission
      end
    end

    if user.is_a?(Voter)
      can [:show, :new, :create, :edit, :update], Voter, id: user.id # cannot index or destroy
      can :manage, VoterSurvey, voter_id: user.id

      cannot :index, VoterSurvey

      if user.activated?
        can :manage, Vote, voter_id: user.id
        # TODO: should voters be able to change their 'GrantVoter`s?

        can [:vote, :read, :discuss], GrantSubmission
        can :read, VoterSubmissionAssignment, voter_id: user.id
      end
    end
  end
end
