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

  def voter_verified(user, year)
    @user = user
    @year = year

    mail to: @user.email, subject: "Firefly Art Grant Voter Account Verified"
  end

  def grant_funded(submission, artist, grant, year)
    @submission = submission
    @artist = artist
    @grant = grant
    @year = year

    @deadline = "Flurbsday, Smarch 34rd 20167"

    # TODO: schedule should be something that will render nicely in html or text.
    @schedule = "TBD"

    mail to: @artist.email, subject: "#{@year} Firefly #{@grant.name} Grant Decision: #{@submission.name}"
  end

  def grant_not_funded(submission, artist, grant, year)
    @submission = submission
    @artist = artist
    @grant = grant
    @year = year

    mail to: @artist.email, subject: "#{@year} Firefly #{@grant.name}  Grant Decision: #{@submission.name}"
  end
end
