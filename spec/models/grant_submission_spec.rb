describe GrantSubmission do
  subject { FactoryGirl.create(:grant_submission) }

  describe '#max_funding_dollars' do
    its(:max_funding_dollars) { is_expected.to eq(subject.grant.max_funding_dollars) }
  end

  context 'validations' do
    context 'with requested_funding_dollars greater than grant limit' do
      it 'is not valid' do
        expect(subject).to be_valid
        subject.requested_funding_dollars = subject.grant.max_funding_dollars + 1
        expect(subject).not_to be_valid
      end
    end
  end
end
