class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= nil

    # TODO: currently checks if it has the class, in the future it will check
    # a `roles` attribute or similar

    # TODO: using `voter_id`, `artist_id` which will become `user_id` in future
    # after models are unified

    # TODO: why do admins not require activation?
    # A: Generally because admins create other admins, but there's no good
    #    reason for this exception.

    # Allow an initial Admin to be crated by anyone
    can :manage, Admin unless Admin.exists?

    can [:new, :create], Artist
    can [:new, :create], Voter

    can [:read, :levels], Grant
    can :read, Tag

    if user.is_a?(Admin)
      can :manage, :all
      can [:grant, :edit_questions, :edit], GrantSubmission
      cannot [:vote, :edit_answers], GrantSubmission
      can :all, GrantsVoter
      can [:all, :view_hidden], Tag
    end

    if user.is_a?(Artist)
      can :manage, Artist, id: user.id
      can :manage, ArtistSurvey, artist_id: user.id

      cannot :index, [Artist, ArtistSurvey]
      cannot :view_hidden, Tag

      if user.activated?
        can [:index, :show, :new, :create, :edit, :update, :destroy, :discuss, :edit_answers, :generate_contract], GrantSubmission, artist_id: user.id
        can :manage, Proposal, grant_submission_id: user.grant_submission_ids

        cannot :destroy, GrantSubmission do |grant_submission|
          grant_submission.funded?
        end
      end
    end

    if user.is_a?(Voter)
      can [:show, :new, :create, :edit, :update, :request_activation], Voter, id: user.id # cannot index or destroy
      can :manage, VoterSurvey, voter_id: user.id
      can :view_hidden, Tag

      cannot :index, VoterSurvey
      cannot [:new, :create, :edit_questions, :edit_answers], GrantSubmission

      if user.activated? and user.verified?
        can :manage, Vote, voter_id: user.id
        # TODO: should voters be able to change their 'GrantVoter`s?
        # A: No, these are assigned by the system.
        can [:vote, :read], GrantSubmission
        can :read, VoterSubmissionAssignment, voter_id: user.id
      end
    end
  end
end
