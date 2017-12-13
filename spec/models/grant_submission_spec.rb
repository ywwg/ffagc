describe GrantSubmission do
  subject { FactoryGirl.create(:grant_submission) }

  describe '#max_funding_dollars' do
    its(:max_funding_dollars) { is_expected.to eq(subject.grant.max_funding_dollars) }
  end

  describe '#funded?' do
    subject { FactoryGirl.create(:grant_submission, funding_decision: false, granted_funding_dollars: nil) }

    it { is_expected.not_to be_funded }

    context 'with funding_decision' do
      subject { FactoryGirl.create(:grant_submission, funding_decision: true, granted_funding_dollars: nil) }

      it { is_expected.not_to be_funded }

      context 'with granted_funding_dollars' do
        subject { FactoryGirl.create(:grant_submission, funding_decision: true, granted_funding_dollars: 1_00) }

        it { is_expected.to be_funded }
      end
    end
  end

  describe '#has_questions?' do
    subject { FactoryGirl.create(:grant_submission, questions: nil) }

    it { is_expected.not_to have_questions }

    context 'with blank questions' do
      subject { FactoryGirl.create(:grant_submission, questions: '       ') }

      it { is_expected.not_to have_questions }
    end

    context 'with questions' do
      subject { FactoryGirl.create(:grant_submission, questions: 'Fake questions') }

      it { is_expected.to have_questions }
    end
  end

  describe '#has_answers?' do
    subject { FactoryGirl.create(:grant_submission, answers: nil) }

    it { is_expected.not_to have_answers }

    context 'with blank answers' do
      subject { FactoryGirl.create(:grant_submission, answers: '       ') }

      it { is_expected.not_to have_answers }
    end

    context 'with answers' do
      subject { FactoryGirl.create(:grant_submission, answers: 'Fake answers') }

      it { is_expected.to have_answers }
    end
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
    let(:frozen_time) { Time.zone.now.round(0) }

    context 'with questions changed' do
      it 'updates questions_updated_at' do
        Timecop.freeze(frozen_time) do
          expect { subject.update(questions: 'New questions.') }.to change { subject.reload.questions_updated_at }.to(frozen_time)
        end
      end
    end

    context 'with answers changed' do
      it 'updates answers_updated_at' do
        Timecop.freeze(frozen_time) do
          expect { subject.update(answers: 'New answers.') }.to change { subject.reload.answers_updated_at }.to(frozen_time)
        end
      end
    end
  end
end
