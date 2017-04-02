shared_examples 'sessions new endpoind' do
  describe '#new' do
    it 'not logged in' do
      get 'new'
      expect(response).to be_ok
    end

    context 'already logged in' do
      before { sign_in user }

      context 'it redirects' do
        it 'redirects to account activation' do
          get 'new'
          expect(response).to be_redirect
        end
      end
    end
  end
end

shared_examples 'sessions create endpoind' do |type_name, session_key, redirect_path|
  describe '#create' do
    def go!(user)
      post 'create', session: { email: user.email.upcase, password: user.password }
    end

    it 'allows logging in with case-insensitive email' do
      expect { go! user }.to change { session[session_key] }.from(nil)
      expect(response).to redirect_to(redirect_path)
    end

    context 'with inactive user' do
      it 'allows logging in with case-insensitive email' do
        expect { go! inactive_user }.to change { session[session_key] }.from(nil)
        expect(response).to redirect_to(redirect_path)
      end
    end
  end
end

shared_examples 'sessions destroy endpoind' do |session_key, redirect_path|
  describe '#destroy' do
    def go!
      delete 'destroy'
    end

    it 'redirects' do
      go!
      expect(response).to redirect_to(redirect_path)
    end

    context 'with logged in' do
      it 'edits session' do
        expect { go! }.to change { session[session_key] }.to('')
        expect(response).to redirect_to(redirect_path)
      end
    end
  end
end
