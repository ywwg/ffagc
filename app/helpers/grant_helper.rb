include ActionView::Helpers::NumberHelper

module GrantHelper
  def funding_levels_pretty(grant)
    if grant.funding_levels_csv == nil || grant.funding_levels_csv == ""
      return ""
    end
    currency_list = []
    grant.funding_levels_csv.split(',').each do |level|
      row = level.strip.split("-")
      if row.length == 1
        currency_list.append(number_to_currency(level, precision: 0))
      else
        currency_list.append("#{number_to_currency(row[0], precision: 0)}-#{number_to_currency(row[1], precision: 0).strip}")
      end
    end
    return currency_list.join(", ")
  end
end
