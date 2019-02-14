# Preview all emails at http://localhost:3000/rails/mailers/user_mailer
class UserMailerPreview < ActionMailer::Preview
  def account_activation
    if artist.activation_token.nil?
      artist.activation_token = ApplicationController.new_token
    end

    UserMailer.account_activation('artists', artist)
  end

  def password_reset
    if artist.reset_token.nil?
      artist.reset_token = ApplicationController.new_token
    end

    UserMailer.password_reset('artists', artist)
  end

  def voter_verified
    UserMailer.voter_verified(voter, '2017')
  end

  def grant_funded
    UserMailer.grant_funded(grant_submission, artist, grant, '2017')
  end

  def grant_not_funded
    UserMailer.grant_not_funded(grant_submission, artist, grant, '2017')
  end

  def notify_questions
    UserMailer.notify_questions(grant_submission, artist, grant, '2017')
  end

  private

  def artist
    @artist ||= Artist.first || FactoryBot.create(:artist, :activated)
  end

  def voter
    @voter ||= Voter.first || FactoryBot.create(:voter, :activated)
  end

  def grant_submission
    @grant_submission ||= GrantSubmission.first || FactoryBot.create(:grant_submission)
  end

  def grant
    @grant ||= Grant.first || FactoryBot.create(:grant)
  end
end
