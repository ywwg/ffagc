module ApplicationHelper
  def safe_blockquote(html_text)
    sanitize(html_text)&.gsub("\n", "<br />")&.html_safe
  end

  def humanize_date(date)
    suffix = if date.past?
      'ago'
    else
      'from now'
    end

    "#{distance_of_time_in_words_to_now(date)} #{suffix}"
  end
end
