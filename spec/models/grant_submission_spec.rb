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

  context 'before_save' do
    context 'with questions changed' do
      it 'updates questions_updated_at' do
        Timecop.freeze do
          expect { subject.update(questions: 'New questions.') }.to change { subject.reload.questions_updated_at }.to(Time.zone.now)
        end
      end
    end

    context 'with answers changed' do
      it 'updates answers_updated_at' do
        Timecop.freeze do
          expect { subject.update(answers: 'New answers.') }.to change { subject.reload.answers_updated_at }.to(Time.zone.now)
        end
      end
    end
  end
end
