describe Admin do
  subject { FactoryBot.build(:admin) }

  include_examples 'password reset model', 'admins'

  context 'before_validation' do
    subject { FactoryBot.build(:admin, email: '  UPPERCASE@example.com ') }

    it 'normalizes email' do
      expect { subject.save! }.to change { subject.email }
      expect(subject.reload.email).to eq('uppercase@example.com')
    end

    it 'activates' do
      expect { subject.save! }.to change { subject.activated }
      expect(subject.activated).to eq(true)
    end

    context 'nil email' do
      subject { FactoryBot.build(:admin, email: nil) }
      its(:valid?) { is_expected.to eq(false) }
    end
  end
end
