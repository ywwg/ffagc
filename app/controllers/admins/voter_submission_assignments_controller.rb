#
# Provides endpoints for an admin to assign GrantSubmissions to verified Voters
# and to delete destroy all VoterSubmissionAssignments
#
class Admins::VoterSubmissionAssignmentsController < ApplicationController
  load_and_authorize_resource

  before_filter :verify_admin

  # distributes voter assignments fairly and can handle newly-added voters and
  # submissions without blowing up existing assignments.
  #
  # First cleans out the assignments from invalid entries.
  #
  # Goes through all grants and for each one gets a list of voters who are
  # verified and are available to vote on that grant.  Then goes through each
  # submission for that grant.  If the submission has fewer assignments than
  # max_voters_per_submission (or the number of voters), we find the voter with
  # the fewest total assignments and give the submission to them.
  def assign
    clean_assignments

    # TEMP HACK
    # NOTE: Keep a list of seen grant submission titles, and if we
    # see a duplicate, skip it. This way artists that submitted at more than
    # one grant level won't appear twice in the voting assignments. This
    # should be removed once we have proper tier selection.
    seen = Set.new

    Grant.includes(:grant_submissions, grants_voters: [:voter]).find_each do |grant|
      voters = grant.voters.where(verified: true).includes(:voter_submission_assignments)

      grant.grant_submissions.each do |gs|
        gs_uid = grant_submission_artist_unique_name(gs)

        if seen.include?(gs_uid)
          next
        else
          seen.add(gs_uid)
        end

        while assigned_count(gs.id) < [max_voters_per_submission, voters.count].min
          voter = fewest_assigned_voter(voters, gs.id)

          VoterSubmissionAssignment.create(
            grant_submission: gs,
            voter: voter
          )
        end
      end
    end

    redirect_to admins_path
  end

  def destroy
    VoterSubmissionAssignment.destroy_all

    redirect_to admins_path
  end

  private

  def max_voters_per_submission
    3
  end

  # Include the Grantsubmission#name *and* artist_id
  # in case two Artists picked the GrantSubmission#name
  def grant_submission_artist_unique_name(grant_submission)
    [grant_submission.name, grant_submission.artist_id]
  end

  # Goes through the voter assignments, and deletes entries if the
  # grant no longer exists or the voter no longer exists.  Unverified voters
  # keep their assignments because their values are ignored, so they can be
  # readded (which happens).
  def clean_assignments
    VoterSubmissionAssignment.find_each do |vsa|
      unless Voter.find_by_id(vsa.voter_id).exist? \
        && GrantSubmission.find_by_id(vsa.grant_submission_id).exist?
        vsa.destroy
      end
    end
  end

  # counts the number of voters a submission is assigned to
  def assigned_count(submission_id)
    VoterSubmissionAssignment.where(grant_submission_id: submission_id).count
  end

  # given a list of voters, returns the voter with the fewest assignments.
  def fewest_assigned_voter(voters, grant_submission)
    fewest = nil
    low_count = -1

    # Randomize order to spread submissions around.
    voters.shuffle.each do |voter|
      next if voter.grant_submissions.include? grant_submission

      count = voter.voter_submission_assignments.count

      if low_count < 0 || count < low_count
        fewest = voter
        low_count = count
      end
    end

    return fewest
  end
end
