describe AccountActivationsController do
  describe '#show' do
    context 'with inactive user' do
      let(:artist) { FactoryGirl.create(:artist) }

      context 'with correct token' do
        def go!
          get 'show', type: 'artists', id: artist.activation_token, email: artist.email
        end

        it 'activates user' do
          expect { go! }.to change { artist.reload.activated? }.from(false).to(true)
        end
      end

      context 'with incorrect token' do
        def go!
          get 'show', type: 'artists', id: 'incorrect_token', email: artist.email
        end

        it 'does not activate' do
          expect { go! }.not_to change { artist.reload.activated? }
        end
      end
    end

    context 'with activated user' do
      let(:artist) { FactoryGirl.create(:artist, :activated) }

      context 'with correct token' do
        def go!
          get 'show', type: 'artists', id: artist.activation_token, email: artist.email
        end

        it do
          expect { go! }.not_to change { artist.reload.activated }.from(true)
        end
      end

      context 'with incorrect token' do
        def go!
          get 'show', type: 'artists', id: 'incorrect_token', email: artist.email
        end

        it do
          expect { go! }.not_to change { artist.reload.activated }.from(true)
        end
      end

      context 'when already logged in as that user' do
        def go!
          get 'show', type: 'artists', id: artist.activation_token, email: artist.email
        end

        before { sign_in artist }

        it 'redirects to root' do
          go!
          expect(response).to redirect_to(root_path)
          expect(flash[:info]).to be_present
        end
      end
    end

    context 'with incorrect email' do
      let(:artist) { FactoryGirl.create(:artist) }

      context 'with incorrect email' do
        it 'shows failure' do
          get 'show', type: 'artists', id: artist.activation_token, email: 'test@example.com'
          expect(response).to render_template('show')
        end
      end
    end
  end

  describe '#create' do
    let(:artist) { FactoryGirl.create(:artist) }

    def go!
      put 'create', type: 'artists', email: artist.email
    end

    context 'with inactive user' do
      it 'creates new activation_digest' do
        expect { go! }.to change { artist.reload.activation_digest }
      end

      it 'sends email' do
        expect(UserMailer).to receive(:account_activation)
        go!
      end
    end

    context 'with incorrect email' do
      def go!
        put 'create', type: 'artists', email: 'incorrect@example.com'
      end

      context 'with incorrect email' do
        it 'shows flash' do
          go!
          expect(flash[:info]).to be_present
          expect(response).to render_template('unactivated')
        end
      end
    end

    context 'with activated user' do
      let(:artist) { FactoryGirl.create(:artist, :activated) }

      it 'shows flash' do
        go!
        expect(flash[:info]).to be_present
        expect(response).to render_template('unactivated')
      end
    end
  end
  end
end
