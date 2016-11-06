ffagc
=====

# Firefly Art Grant Core Website

## Initial Environment Setup

build / install stuff I dunno who even uses rails any more:

    rake
    bundle update
    bundle install

You'll need to create config/secrets.yml with the form:

    development:
      secret_key_base: [[[LOTS OF HEX]]]

    test:
      secret_key_base: [[[LOTS OF HEX]]]

    production:
      secret_key_base: <%= ENV["SECRET_KEY_BASE"] %>

Use 'rake secret' to generate the hex.  Don't check this file into source control!

## Email Setup

If you plan to send email, you'll need to create config/initializers/smtp_secret.rb
with:

    ENV['PASSWORD']="your smtp password"

and edit config/environments/*.rb to include your smtp server information.

## Event-Specific Setup (do this every year)

It's recommended that you delete the database every year, but there's also a few code
changes you should make.

Set the year of the event (e.g., "Apply for Firefly 2027!") in config/application.rb.

You'll also need to update the grant contract generation in lib/pdf/grant_contract.rb.

Grant contract templates will need to be updated with the correct dates.

## Initialize the Database

init the db with:

    bin/rake db:migrate RAILS_ENV=development

or delete an existing db:

    bin/rake db:reset

## Run Tests

    bin/rake

## Launch the server

Run the server, which runs on the default port 3000:

    bin/rails server

You should create an admin right away by going to the admins page.


# Troubleshooting

I had problems with bundle install not working, and I had to do:

    bundle install --deployment

If you find that some assets are not updating, like css, they have probably been precompiled
with a command like:

    RAILS_ENV=production bundle exec rake assets:precompile


