shared_examples 'activatable model' do
  context 'on create' do
    its(:activation_token) { is_expected.to be_nil }

    context 'after save' do
      it 'has activation_token' do
        subject.save!
        expect(subject.reload.activation_token).not_to be_nil
      end
    end
  end
end
