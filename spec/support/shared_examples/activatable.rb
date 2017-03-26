shared_examples 'activatable model' do
  context 'on create' do
    its(:activation_token) { is_expected.to be_nil }
    its(:activation_digest) { is_expected.to be_nil }

    context 'after save' do
      before { subject.save! }

      it 'has activation_token' do
        expect(subject.reload.activation_token).not_to be_nil
      end

      it 'has activation_digest' do
        expect(subject.reload.activation_digest).not_to be_nil
      end
    end
  end
end
