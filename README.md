ffagc
=====

# Firefly Art Grant Core Website

## Initial Environment Setup

build / install stuff I dunno who even uses rails any more:

    rake
    bundle update
    bundle install

If you are running this project in production you'll need to set environment variables for secrets that include `ENV` in `config/secrets.yml`.

## Email Setup

If using SMTP set the required ENV variables or fill in (and do not commit) `.env` like so:

```sh
SMTP_PASSWORD='this_is_not_the_password'
```

## Event-Specific Setup (do this every year)

It's recommended that you delete the database every year, but there's also a few config
changes you should make:

* Set the year of the event (e.g., "Apply for Firefly 2027!") in config/application.rb.

* Check the grant contract templates in app/assets/contract_templates.  Each template filename
must match the corresponding grant name, so if a grant changes name the template filename must
also be changed.

* Update the template constants (install dates and deadlines) in config/template_values.yml.

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
