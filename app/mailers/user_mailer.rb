class UserMailer < ActionMailer::Base
  default from: "grants@fireflyartscollective.org"

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.account_activation.subject
  #
  def account_activation(type, user)
    @user = user
    @type = type

    mail to: user.email, subject: "Firefly Art Grant Account Activation"
  end

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.password_reset.subject
  #
  def password_reset(type, user)
    @user = user
    @type = type

    mail to: user.email, subject: "Firefly Art Grant Password Reset"
  end
end
