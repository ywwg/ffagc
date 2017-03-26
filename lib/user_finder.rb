class UserFinder
  def self.find_by_email(type, email)
    email = normalize_email(email)

    if type == 'artists'
      Artist.find_by(email: email)
    elsif type == 'voters'
      Voter.find_by(email: email)
    elsif type == 'admins'
      Admin.find_by(email: email)
    else
      nil
    end
  end

  def self.find_by_email!(type, email)
    user = find_by_email(type, email)

    if user.nil?
      raise ActiveRecord::RecordNotFound
    end

    user
  end

  private

  def self.normalize_email(email)
    URI.unescape(email).downcase
  end
end
