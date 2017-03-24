describe ApplicationController do
  describe '#timezone_string' do
    its(:timezone_string) { is_expected.to eq('-05:00') }
  end
end
