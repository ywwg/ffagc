describe AccountActivationsController do
  describe '#edit' do
    context 'with inactive user' do
      let(:artist) { FactoryGirl.create(:artist) }

      context 'with correct token' do
        it 'activates user' do
          put 'edit', { type: 'artists', id: artist.activation_token, email: artist.email }
          expect(artist.reload).to be_activated
          expect(response).to render_template('success')
        end
      end

      context 'with incorrect token' do
        it 'shows failure' do
          put 'edit', { type: 'artists', id: 'incorrect_token', email: artist.email }
          expect(artist.reload).not_to be_activated
          expect(response).to render_template('failure')
        end
      end
    end

    context 'with activated user' do
      let(:artist) { FactoryGirl.create(:artist, :activated) }

      context 'with correct token' do
        it 'shows success' do
          put 'edit', { type: 'artists', id: artist.activation_token, email: artist.email }
          expect(response).to render_template('success')
        end
      end
    end

    context 'with incorrect email' do
      let(:artist) { FactoryGirl.create(:artist) }

      context 'with incorrect email' do
        it 'shows failure' do
          put 'edit', { type: 'artists', id: artist.activation_token, email: 'test@example.com' }
          expect(response).to render_template('failure')
        end
      end
    end
  end

  describe "#unactivated" do
    it 'returns ok' do
      get 'unactivated'
      expect(response).to be_ok
    end
  end
end
