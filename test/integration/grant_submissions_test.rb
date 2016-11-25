require 'test_helper'

class GrantSubmissionsTest < ActionDispatch::IntegrationTest

  def setup
    @grant_submission = grant_submissions(:wall)
  end

  test "artist_discuss" do
    @artist = artists(:michael)
    sign_in_artist(@artist, 'password')

    # bad id
    get grant_submissions_discuss_path(id: 20, authenticity_token: "abc")
    assert_redirected_to "/"

    # not ours
    get grant_submissions_discuss_path(id: 2, authenticity_token: "abc")
    assert_redirected_to "/"

    # good id
    get grant_submissions_discuss_path(id: 1, authenticity_token: "abc")
    assert_template 'grant_submissions/discuss'

    # this is an artist, so we can edit the answers but not questions
    assert_select 'textarea#grant_submission_questions[disabled=?]', 'disabled'
    # There has got to be an easier way to test for nonexistence of an attr.
    assert_select 'textarea#grant_submission_answers' do |e|
      e.each do |t|
        assert !t.attributes.has_key?('disabled')
      end
    end
  end

  test "voter_discuss" do
    @voter = voters(:urmam)
    sign_in_voter(@voter, 'password')

    # bad id
    get grant_submissions_discuss_path(id: 200, authenticity_token: "abc")
    assert_redirected_to "/"

    # any good id is ok
    get grant_submissions_discuss_path(id: 2, authenticity_token: "abc")
    assert_template 'grant_submissions/discuss'

    # good id
    get grant_submissions_discuss_path(id: 1, authenticity_token: "abc")
    assert_template 'grant_submissions/discuss'

    # this is a voter, can't edit either
    assert_select 'textarea#grant_submission_questions[disabled=?]', 'disabled'
    assert_select 'textarea#grant_submission_answers[disabled=?]', 'disabled'
  end

  test "admin_discuss" do
    @admin = admins(:one)
    sign_in_admin(@admin, 'password')

    # bad id
    get grant_submissions_discuss_path(id: 200, authenticity_token: "abc")
    assert_redirected_to "/"

    # any good id is ok
    get grant_submissions_discuss_path(id: 2, authenticity_token: "abc")
    assert_template 'grant_submissions/discuss'

    # good id
    get grant_submissions_discuss_path(id: 1, authenticity_token: "abc")
    assert_template 'grant_submissions/discuss'

    # this is an admin, can edit both
    assert_select 'textarea#grant_submission_questions' do |e|
      e.each do |t|
        assert !t.attributes.has_key?('disabled')
      end
    end
    assert_select 'textarea#grant_submission_answers' do |e|
      e.each do |t|
        assert !t.attributes.has_key?('disabled')
      end
    end
  end

end