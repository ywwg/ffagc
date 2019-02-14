describe ArtistSurvey do
  subject { FactoryBot.build(:artist_survey) }

  # smoke test
  its(:valid?) { is_expected.to be(true) }
end
