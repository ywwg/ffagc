ffagc
=====

Firefly Art Grant Core Website

build / install stuff I dunno:

    rake
    bundle update
    bundle install

need to create config/secrets.yml with the form:

    development:
      secret_key_base: [[[LOTS OF HEX]]]
    
    test:
      secret_key_base: [[[LOTS OF HEX]]]
    
    production:
      secret_key_base: <%= ENV["SECRET_KEY_BASE"] %>
  
use rake secret to generate some hex

init the db with:

    bin/rake db:migrate RAILS_ENV=development

run the server:

    bin/rails server

create an admin:
    bin/rails console
    irb(main):005:0* class Admin < ActiveRecord::Base
    irb(main):006:1>   has_secure_password
    irb(main):007:1> end
    => nil
    irb(main):043:0> BCrypt::Password.create("SOMETHING THAT's NOT THIS")
=> "ABUNCHOFJUNK"
    irb(main):008:0> admin = Admin.new(:name => "owen", :email => "owen@ywwg.com", :password_digest => "ABUNCHOFJUNK")
    => #<Admin id: nil, name: "owen", email: "owen@ywwg.com", created_at: nil, updated_at: nil, password_digest: "ABUNCHOFJUNK">
    irb(main):009:0> admin.save
       (0.3ms)  begin transaction
      SQL (0.5ms)  INSERT INTO "admins" ("created_at", "email", "name", "password_digest", "updated_at") VALUES (?, ?, ?, ?, ?)  [["created_at", "2016-08-28 18:03:44.477688"], ["email", "owen@ywwg.com"], ["name", "owen"], ["password_digest", "ABUNCHOFJUNK"], ["updated_at", "2016-08-28 18:03:44.477688"]]
       (17.2ms)  commit transaction
    => true

And then I can log in as an admin! amazeballs.
