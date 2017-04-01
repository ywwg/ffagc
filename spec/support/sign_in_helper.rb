def sign_in(user)
  if user.is_a?(Admin)
    sign_in_admin(user.id)
  elsif user.is_a?(Artist)
    sign_in_artist(user.id)
  elsif user.is_a?(Voter)
    sign_in_voter(user.id)
  end
end

def sign_in_artist(artist_id)
  @request.session['artist_id'] = artist_id
end

def sign_in_voter(voter_id)
  @request.session['voter_id'] = voter_id
end

def sign_in_admin(admin_id)
  @request.session['admin_id'] = admin_id
end
