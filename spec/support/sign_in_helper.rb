def sign_in_artist(artist_id)
  @request.session['artist_id'] = artist_id
end

def sign_in_voter(voter_id)
  @request.session['voter_id'] = voter_id
end

def sign_in_admin(admin_id)
  @request.session['admin_id'] = admin_id
end
