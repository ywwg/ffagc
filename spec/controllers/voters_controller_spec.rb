describe VotersController do
  describe "#signup" do
    it 'returns ok' do
      get 'signup'
      expect(response).to be_ok
    end
  end
end
