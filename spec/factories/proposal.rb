FactoryGirl.define do
  factory :proposal do
    grant_submission
    file { File.open(File.join(Rails.root, 'spec/fixtures/proposals/example.png')) }
  end
end
