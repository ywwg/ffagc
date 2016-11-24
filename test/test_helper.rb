ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  def sign_in_artist(user, password)
    post artists_login_path(session: {email: user.email, password: password})
    assert_redirected_to '/artists'
  end

  def sign_in_voter(user, password)
    post voters_login_path(session: {email: user.email, password: password})
    assert_redirected_to '/voters'
  end

  def sign_in_admin(user, password)
    post admins_login_path(session: {email: user.email, password: password})
    assert_redirected_to '/admins'
  end
end
