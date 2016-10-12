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

end
