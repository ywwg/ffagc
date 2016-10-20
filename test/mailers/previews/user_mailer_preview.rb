# Preview all emails at http://localhost:3000/rails/mailers/user_mailer
class UserMailerPreview < ActionMailer::Preview

  # Preview this email at http://localhost:3000/rails/mailers/user_mailer/account_activation
  def account_activation
    user = Artist.first
    user.activation_token = ApplicationController.new_token
    UserMailer.account_activation("artists", user)
  end

  # Preview this email at http://localhost:3000/rails/mailers/user_mailer/password_reset
  def password_reset
    user = Artist.first
    user.reset_token = ApplicationController.new_token
    UserMailer.password_reset("artists", user)
  end
  
  # Preview this email at http://localhost:3000/rails/mailers/user_mailer/voter_verified
  def voter_verified
    user = Voter.first
    UserMailer.voter_verified(user, "2017")
  end
  
  # http://localhost:3000/rails/mailers/user_mailer/grant_funded
  def grant_funded
    submission = GrantSubmission.first
    artist = Artist.first
    grant = Grant.first
    UserMailer.grant_funded(submission, artist, grant, "2017")
  end
  
  # http://localhost:3000/rails/mailers/user_mailer/grant_not_funded
  def grant_not_funded
    submission = GrantSubmission.first
    artist = Artist.first
    grant = Grant.first
    UserMailer.grant_not_funded(submission, artist, grant, "2017")
  end

end
