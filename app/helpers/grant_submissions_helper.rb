module GrantSubmissionsHelper
  def discussion_status(grant_submission)
    "#{q_and_a_status(grant_submission)} (#{grant_submission.proposals.count}&nbsp;#{'doc'.pluralize(grant_submission.proposals.count)})".html_safe
  end

  def q_and_a_status(grant_submission)
    discuss = []
    discuss.push("Q") if grant_submission.has_questions?
    discuss.push("A") if grant_submission.has_answers?
    discuss.push("None") if discuss.empty?
    discuss.join('&').squeeze(' ')
  end
end
