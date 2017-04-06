#
# Provides endpoints for an admin to assign GrantSubmissions to verified Voters
# and to delete destroy all VoterSubmissionAssignments
#
class Admins::VoterSubmissionAssignmentsController < ApplicationController
  load_and_authorize_resource

  before_filter :verify_admin

  # Distributes voter assignments fairly. Can handle newly-added Voters and
  # GrantSubmissions without changing existing assignments.
  #
  # Does NOT guarantee that a new Voter will get any assignments if all
  # GrantSubmissions already have enough Voters.
  #
  # Cleans any existing invalid VoterSubmissionAssignments.
  #
  # Goes through each unique GrantSubmission and assigns eligible voters to that
  # GrantSubmission choosing Voters with fewest VoterSubmissionAssignments first.
  # Will not assign more than Grantsubmission#max_voters Voters to a GrantSubmission.
  #
  # If a GrantSubmission needs more Voters but non are eligible nothing happens for
  # that GrantSubmission.
  #
  # Will not assign a Voter the same GrantSubmission more than once.
  def assign
    clean_assignments

    unique_grant_submissions.each do |grant_submission|
      # find voters not assigned this grant
      voters = grant_submission.grant.voters
        .includes(:voter_submission_assignments, :grant_submissions)
        .where(verified: true)

      # eligible_voters must not already be assigned to this grant_submission
      eligible_voters = voters.reject do |voter|
        voter.grant_submissions.include?(grant_submission)
      end

      # Sort by least number of voter_submission_assignments. The order for
      # voters with the same number of voter_submission_assignment is randomized.
      #
      # Take only as many as are required to give grant_submission the desired
      # number of voters.
      voters_to_assign = eligible_voters
        .shuffle
        .sort_by { |voter| voter.voter_submission_assignments.count }
        .take(grant_submission.num_voters_to_assign)

      voters_to_assign.each do |voter|
        VoterSubmissionAssignment.create!(
          grant_submission: grant_submission,
          voter: voter
        )
      end
    end

    redirect_to admins_path
  end

  def destroy
    VoterSubmissionAssignment.destroy_all

    redirect_to admins_path
  end

  private

  def unique_grant_submissions
    # TEMP HACK
    # NOTE: Keep a list of seen grant submission titles, and if we
    # see a duplicate, skip it. This way artists that submitted at more than
    # one grant level won't appear twice in the voting assignments. This
    # should be removed once we have proper tier selection.
    seen = Set.new

    unique_grant_submissions = []

    Grant.includes(grant_submissions: [:artist]).find_each do |grant|
      unique_grant_submissions << grant.grant_submissions.select do |grant_submission|
        # Include the Grantsubmission#name *and* artist_id in case
        # two Artists picked the same GrantSubmission#name
        gs_uid = [grant_submission.name, grant_submission.artist_id]

        unless seen.include?(gs_uid)
          seen.add(gs_uid)
          true
        end
      end
    end

    unique_grant_submissions.flatten
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
end
