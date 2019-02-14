describe Artist do
  subject { FactoryBot.build(:artist) }

  include_examples 'activatable model'
  include_examples 'password reset model', 'artists'

  context 'with country name in contact_country' do
    subject { FactoryBot.build(:artist, contact_country: 'Canada') }
    its(:valid?) { is_expected.to be(false) }
  end
end
