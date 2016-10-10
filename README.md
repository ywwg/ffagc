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

if you plan to send email, you'll need to create config/initializers/smtp_secret.rb
with:
    ENV['PASSWORD']="your smtp password"
    
and edit config/environments/*.rb to include your smtp server information.


init the db with:

    bin/rake db:migrate RAILS_ENV=development

run the server, default port 3000:

    bin/rails server

create an admin right away by going to the admins page.
