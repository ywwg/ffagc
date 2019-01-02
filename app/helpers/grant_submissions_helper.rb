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

  def funding_requests_pretty(gs)
    if gs.funding_requests_csv == nil || gs.funding_requests_csv == ""
      return ""
    end
    currency_list = []
    gs.funding_requests_csv.split(',').each do |level|
      currency_list.append(number_to_currency(level, precision: 0))
    end
    return currency_list.join(", ")
  end
end
