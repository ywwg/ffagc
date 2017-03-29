ffagc
=====

# Firefly Art Grant Core Website

## Initial Environment Setup

Set up the project with:

```sh
  bundle install
  bundle exec rake db:migrate RAILS_ENV=development
  bundle exec rails server
```

If you are running this project in production you'll need to set environment variables for secrets that include `ENV` in `config/secrets.yml`.

## Email Setup

If using SMTP set the required ENV variables or fill in (and do not commit) `.env` like so:

```sh
SMTP_PASSWORD='this_is_not_the_password'
```

## Event-Specific Setup (do this every year)

There are a few changes to make every year:

* Set the year of the event (e.g., "Apply for Firefly 2027!") in config/application.rb.

* Check the grant contract templates in app/assets/contract_templates.  Each template filename
must match the corresponding grant name, so if a grant changes name the template filename must
also be changed.

* Update the template constants (install dates and deadlines) in config/template_values.yml.

* Reset the database with `bundle exec rake db:reset`. THIS WILL DELETE ALL DATA.

## Run Tests

```sh
  bundle exec rspec
```

## Launch the server

Run the server, which runs on the default port 3000:

```sh
  bundle exec rails s
```

You should create an admin right away by going to the admins page.

# Troubleshooting

I had problems with bundle install not working, and I had to do:

```sh
  bundle install --deployment
```
