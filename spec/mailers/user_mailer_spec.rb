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

    context 'without notes' do
      let!(:grant_submission) {
        FactoryGirl.create(:grant_submission, artist: artist, grant: grant,
          funding_requests_csv: "5000", granted_funding_dollars: 800) }

      subject { UserMailer.grant_funded(grant_submission, artist, grant, '2020') }

      its(:subject) { is_expected.to eq("2020 Firefly Creativity Grant Decision: #{grant_submission.name}") }
      its(:from) { is_expected.to include('grants@fireflyartscollective.org') }
      its(:to) { is_expected.to eq([artist.email]) }

      it do
        expect(subject.body.encoded).to include('Congratulations')
        expect(subject.body.encoded).to include('$800')
      end
    end

    context 'with blank notes' do
      let!(:grant_submission) {
        FactoryGirl.create(:grant_submission, artist: artist, grant: grant,
          funding_requests_csv: "5000", granted_funding_dollars: 800,
          public_funding_notes: "") }

      subject { UserMailer.grant_funded(grant_submission, artist, grant, '2020') }

      its(:subject) { is_expected.to eq("2020 Firefly Creativity Grant Decision: #{grant_submission.name}") }
      its(:from) { is_expected.to include('grants@fireflyartscollective.org') }
      its(:to) { is_expected.to eq([artist.email]) }

      it do
        expect(subject.body.encoded).to include('Congratulations')
        expect(subject.body.encoded).to include('$800')
        # Shouldn't include empty paragraph
        expect(subject.body.encoded).not_to include('<p></p>')
      end
    end

    context 'with notes' do
      let!(:grant_submission) {
        FactoryGirl.create(:grant_submission, artist: artist, grant: grant,
          funding_requests_csv: "5000", granted_funding_dollars: 800,
          private_funding_notes: "NOTINCLUDED",
          public_funding_notes: "SOMENOTES") }

      subject { UserMailer.grant_funded(grant_submission, artist, grant, '2020') }

      its(:subject) { is_expected.to eq("2020 Firefly Creativity Grant Decision: #{grant_submission.name}") }
      its(:from) { is_expected.to include('grants@fireflyartscollective.org') }
      its(:to) { is_expected.to eq([artist.email]) }

      it do
        expect(subject.body.encoded).to include('Congratulations')
        expect(subject.body.encoded).to include('$800')
        expect(subject.body.encoded).not_to include('NOTINCLUDED')
        expect(subject.body.encoded).to include('<p>SOMENOTES</p>')
      end
    end
  end

  describe '#grant_not_funded' do
    let!(:grant) { FactoryGirl.create(:grant, name: 'Creativity') }

    context 'without notes' do
      let!(:grant_submission) {
        FactoryGirl.create(:grant_submission, artist: artist, grant: grant,
          funding_requests_csv: "5000")
        }

      subject { UserMailer.grant_not_funded(grant_submission, artist, grant, '2020') }

      its(:subject) { is_expected.to eq("2020 Firefly Creativity Grant Decision: #{grant_submission.name}") }
      its(:from) { is_expected.to include('grants@fireflyartscollective.org') }
      its(:to) { is_expected.to eq([artist.email]) }

      it do
        expect(subject.body.encoded).to include('regret')
      end
    end

    context 'with notes' do
      let!(:grant_submission) {
        FactoryGirl.create(:grant_submission, artist: artist, grant: grant,
          funding_requests_csv: "5000", private_funding_notes: "NOTINCLUDED",
          public_funding_notes: "SOMENOTES")
        }

      subject { UserMailer.grant_not_funded(grant_submission, artist, grant, '2020') }

      its(:subject) { is_expected.to eq("2020 Firefly Creativity Grant Decision: #{grant_submission.name}") }
      its(:from) { is_expected.to include('grants@fireflyartscollective.org') }
      its(:to) { is_expected.to eq([artist.email]) }

      it do
        expect(subject.body.encoded).to include('regret')
        expect(subject.body.encoded).not_to include('NOTINCLUDED')
        expect(subject.body.encoded).to include('SOMENOTES')
      end
    end
  end
end
