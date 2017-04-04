module GrantSubmissionsHelper
  def discussion_status(grant_submission)
    discuss = []

    discuss.push("Q") if grant_submission.has_questions?
    discuss.push("A") if grant_submission.has_answers?

    status = discuss.join('&').squeeze(' ') || 'None'

    status += ", #{pluralize(grant_submission.proposals.count, 'doc')}"

    status
  end
end
