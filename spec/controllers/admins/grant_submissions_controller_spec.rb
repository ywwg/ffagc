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

  describe '#send_fund_emails' do
    def go!
      post 'send_fund_emails'
    end

    context 'logged out' do
      it 'is forbidden' do
        go!
        expect(response).to be_forbidden
      end
    end

    context 'logged in' do
      let!(:admin) { FactoryGirl.create(:admin) }

      before do
        sign_in_admin(admin.id)
        go!
      end

      it { is_expected.to be_ok }
    end
  end

  describe '#send_question_emails' do
    def go!
      post 'send_question_emails'
    end

    context 'logged out' do
      it 'is forbidden' do
        go!
        expect(response).to be_forbidden
      end
    end

    context 'logged in' do
      let!(:admin) { FactoryGirl.create(:admin) }

      before do
        sign_in_admin(admin.id)
        go!
      end

      it { is_expected.to be_ok }
    end
  end
end
