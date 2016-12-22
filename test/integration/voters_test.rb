require 'test_helper'

class VotersTest < ActionDispatch::IntegrationTest
  test "index_sanity" do
    get voters_path
    assert_template "index"
    
    @voter = voters(:urmam)
    sign_in_voter(@voter, 'password')
    get voters_path
    assert_template "index"
  end
end
