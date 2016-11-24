require 'test_helper'

class PasswordResetsTest < ActionDispatch::IntegrationTest

  def setup
    ActionMailer::Base.deliveries.clear
    @user = artists(:michael)
  end

  test "password resets" do
    get new_password_reset_path(type: "artists")
    assert_template 'password_resets/new'
    # Invalid email
    post password_resets_path, password_reset: { email: "", type:"artists" }
    assert_not flash.empty?
    assert_template 'password_resets/new'
    # Valid email
    post password_resets_path,
          password_reset: { email: @user.email, type:"artists"  }
    assert_not_equal @user.reset_digest, @user.reload.reset_digest
    assert_equal 1, ActionMailer::Base.deliveries.size
    assert_not flash.empty?
    assert_template 'password_resets/failure'
    # Password reset form
    user = assigns(:user)
    # Wrong email
    get edit_password_reset_path(user.reset_token, email: "", type: "artists")
    assert_template 'password_resets/failure'
    # Inactive user
    user.toggle!(:activated)
    get edit_password_reset_path(user.reset_token, email: user.email, type: "artists")
    assert_template 'password_resets/failure'
    user.toggle!(:activated)
    # Right email, wrong token
    get edit_password_reset_path('wrong token', email: user.email, type: "artists")
    assert_template 'password_resets/failure'
    # Right email, right token
    get edit_password_reset_path(user.reset_token, email: user.email, type: "artists")
    assert_template 'password_resets/edit'
    assert_select "input[name=email][type=hidden][value=?]", user.email
    # Invalid password & confirmation
    patch password_reset_path(user.reset_token, email: user.email, type: "artists",
                    artist: { password:              "foobaz",
                              password_confirmation: "barquux" } )
    assert_not flash.empty?
    # Empty password
    patch password_reset_path(user.reset_token, email: user.email, type: "artists",
                    artist: { password:              "",
                              password_confirmation: "" } )
    assert_not flash.empty?

    # Valid password & confirmation
    patch password_reset_path(user.reset_token, email: user.email, type: "artists",
                    artist: { password:              "foobaz",
                              password_confirmation: "foobaz" } )
    assert flash.empty?
    assert_template "success"
  end
end