describe UserMailer do
  let(:artist) { FactoryGirl.create(:artist, :activated) }

  describe '#account_activation' do
    before do
      artist.activation_token = ApplicationController.new_token
    end

    subject { UserMailer.account_activation('artists', artist) }

    its(:subject) { is_expected.to eq('Firefly Art Grant Account Activation') }
    its(:from) { is_expected.to include('grants@fireflyartscollective.org') }
    its(:to) { is_expected.to eq([artist.email]) }

    it do
      expect(subject.body.encoded).to include(artist.name)
      expect(subject.body.encoded).to include(artist.activation_token)
      expect(subject.body.encoded).to include(CGI.escape(artist.email))
    end
  end

  describe '#password_reset' do
    before do
      artist.reset_token = ApplicationController.new_token
    end

    subject { UserMailer.password_reset('artists', artist) }

    its(:subject) { is_expected.to eq('Firefly Art Grant Password Reset') }
    its(:from) { is_expected.to include('grants@fireflyartscollective.org') }
    its(:to) { is_expected.to eq([artist.email]) }

    it do
      expect(subject.body.encoded).to include(artist.name)
      expect(subject.body.encoded).to include(artist.reset_token)
      expect(subject.body.encoded).to include(CGI.escape(artist.email))
    end
  end

  describe '#grant_funded' do
    let!(:grant) { FactoryGirl.create(:grant, name: 'Creativity') }
    let!(:grant_submission) { FactoryGirl.create(:grant_submission, artist: artist, grant: grant, granted_funding_dollars: 800) }

    subject { UserMailer.grant_funded(grant_submission, artist, grant, '2020') }

    its(:subject) { is_expected.to eq("2020 Firefly Creativity Grant Decision: #{ grant_submission.name }") }
    its(:from) { is_expected.to include('grants@fireflyartscollective.org') }
    its(:to) { is_expected.to eq([artist.email]) }

    it do
      expect(subject.body.encoded).to include('Congratulations')
      expect(subject.body.encoded).to include("$800")
    end
  end

  describe '#grant_not_funded' do
    let!(:grant) { FactoryGirl.create(:grant, name: 'Creativity') }
    let!(:grant_submission) { FactoryGirl.create(:grant_submission, artist: artist, grant: grant) }

    subject { UserMailer.grant_not_funded(grant_submission, artist, grant, '2020') }

    its(:subject) { is_expected.to eq("2020 Firefly Creativity Grant Decision: #{ grant_submission.name }") }
    its(:from) { is_expected.to include('grants@fireflyartscollective.org') }
    its(:to) { is_expected.to eq([artist.email]) }

    it do
      expect(subject.body.encoded).to include('regret')
    end
  end
end
