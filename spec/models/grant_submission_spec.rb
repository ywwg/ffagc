describe GrantSubmission do
  let!(:grant) { FactoryGirl.create(:grant) }
  subject { FactoryGirl.create(:grant_submission, grant: grant) }

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

  # TODO: need to add a test for comparing csv of requests with csv levels
  context 'validations' do
    context 'with funding_requests_csv greater than grant limit' do
      subject { FactoryGirl.create(:grant_submission) }

      it 'is not valid' do
         subject.funding_requests_csv = "5001"
         expect(subject).to_not be_valid
      end
    end
  end

  # Time comparisons lose precision when saved to the db:
  # https://stackoverflow.com/questions/20403063/trouble-comparing-time-with-rspec
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
