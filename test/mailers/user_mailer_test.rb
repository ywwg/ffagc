require 'test_helper'

class UserMailerTest < ActionMailer::TestCase
  test "account_activation" do
    user = artists(:michael)
    user.activation_token = ApplicationController.new_token
    mail = UserMailer.account_activation("artists", user)
    assert_equal "Firefly Art Grant Account Activation", mail.subject
    assert_equal ["michael@example.com"], mail.to
    assert_equal ["grants@fireflyartscollective.org"], mail.from
    assert_match user.name,               mail.body.encoded
    assert_match user.activation_token,   mail.body.encoded
    assert_match CGI.escape(user.email),  mail.body.encoded
  end

  test "password_reset" do
    user = artists(:michael)
    user.activation_token = ApplicationController.new_token
    mail = UserMailer.password_reset("artists", user)
    assert_equal "Firefly Art Grant Password Reset", mail.subject
    assert_equal ["michael@example.com"], mail.to
    assert_equal ["grants@fireflyartscollective.org"], mail.from
    # assert_match user.name,               mail.body.encoded
    # assert_match user.activation_token,   mail.body.encoded
    # assert_match CGI.escape(user.email),  mail.body.encoded
  end

end
