describe Vote do
  subject { FactoryGirl.build(:vote) }

  # smoke test
  its(:valid?) { is_expected.to be(true) }

  context 'all scores nil' do
    subject { FactoryGirl.build(:vote, score_c: nil, score_t: nil, score_f: nil) }

    its(:valid?) { is_expected.to be(true) }
  end
end
