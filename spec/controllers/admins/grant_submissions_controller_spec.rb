describe Admins::GrantSubmissionsController do
  subject { response }

  describe '#index' do
    def go!
      get :index
    end

    it { go!; is_expected.to be_forbidden }

    context 'when admin signed in' do
      let!(:admin) { FactoryGirl.create(:admin) }

      before { sign_in admin }

      it 'is ok' do
        go!
        expect(response).to render_template('index')
        expect(response).to be_ok
      end
    end
  end
end
