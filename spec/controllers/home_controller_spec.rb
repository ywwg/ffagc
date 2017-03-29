describe HomeController do
  describe '#index' do
    it 'returns ok' do
      get :index
      expect(response).to be_ok
    end
  end
end
