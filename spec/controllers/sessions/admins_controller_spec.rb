describe Sessions::AdminsController do
  let!(:user) { FactoryGirl.create(:admin, :activated) }
  let!(:inactive_user) { FactoryGirl.create(:admin) }

  describe '#new' do
    it_behaves_like 'sessions new endpoind'
  end

  describe '#create' do
    it_behaves_like 'sessions create endpoind', 'admins', 'admin_id', '/grant_submissions'
  end

  describe '#destroy' do
    it_behaves_like 'sessions destroy endpoind', 'admin_id', '/'
  end
end
