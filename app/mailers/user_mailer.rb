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

    mail to: @user.email, subject: "Firefly Art Grant Account Activation"
  end

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.password_reset.subject
  #
  def password_reset(type, user)
    @user = user
    @type = type

    mail to: @user.email, subject: "Firefly Art Grant Password Reset"
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

    # TODO: this is not a great place to store this kind of info, but it's too
    # specific to put in the DB.  Unless I make a key-value store for this kind
    # of arbitrary string.
    @deadline = "Flurbsday, Smarch 34rd 20167"

    # TODO: schedule should be something that will render nicely in html or text.
    @schedule = "TBD"

    cc = ""
    if Rails.env.production?
      cc = "grants@fireflyartscollective.org"
    end

    mail to: @artist.email, cc: cc, subject: "#{@year} Firefly #{@grant.name} Grant Decision: #{@submission.name}"
  end

  def grant_not_funded(submission, artist, grant, year)
    @submission = submission
    @artist = artist
    @grant = grant
    @year = year

    cc = ""
    if Rails.env.production?
      cc = "grants@fireflyartscollective.org"
    end

    mail to: @artist.email, cc: cc, subject: "#{@year} Firefly #{@grant.name} Grant Decision: #{@submission.name}"
  end

  def notify_questions(submission, artist, grant, year)
    @submission = submission
    @artist = artist
    @grant = grant
    @year = year

    # TODO: due_date should also not be set here, because no one will ever find it.
    @due_date = "TBD"

    cc = ""
    if Rails.env.production?
      cc = "grants@fireflyartscollective.org"
    end

    mail to: @artist.email, cc: cc, subject: "#{@year} Firefly #{@grant.name} Grants: Questions regarding #{@submission.name}"
  end
end
