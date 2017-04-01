module ApplicationHelper
  def safe_blockquote(html_text)
    sanitize(html_text)&.gsub("\n", "<br />")&.html_safe
  end
end
