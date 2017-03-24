describe AccountActivationsController do
  describe "#unactivated" do
    it 'returns ok' do
      get 'unactivated'
      expect(response).to be_ok
    end
  end
end
