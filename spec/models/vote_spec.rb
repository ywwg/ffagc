describe Vote do
  subject { FactoryBot.build(:vote) }

  # smoke test
  its(:valid?) { is_expected.to be(true) }

  context 'all scores nil' do
    subject { FactoryBot.build(:vote, score_c: nil, score_t: nil, score_f: nil) }

    its(:valid?) { is_expected.to be(true) }
  end

  context 'score above 2' do
    subject { FactoryBot.build(:vote, score_c: 3, score_t: 4, score_f: 5) }

    it 'has expected errors' do
      expect(subject).not_to be_valid
      expect(subject.errors).to include(:score_c, :score_t, :score_f)
    end
  end

  context 'negative score' do
    subject { FactoryBot.build(:vote, score_c: -1, score_t: -2, score_f: -3) }

    it 'has expected errors' do
      expect(subject).not_to be_valid
      expect(subject.errors).to include(:score_c, :score_t, :score_f)
    end
  end
end
