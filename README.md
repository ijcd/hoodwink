## Development

In order to work on Hoodwink you first need to fork and clone the repo.
Please do any work on a dedicated branch and rebase against master
before sending a pull request.

#### Running Tests

We use RVM in order to test Hoodwink against 1.8.6, REE, 1.8.7, 1.9.2 and
jRuby.  You can get RVM setup for Hoodwink development using the
following commands (if you don't have these version of Ruby installed
use `rvm install` to install each of them).

    for version in 1.8.6 ree 1.8.7 1.9.2 jruby do
      rvm use --create $version@hoodwink
      gem install bundler
      bundle install
    end

These commands will create a gemset named Hoodwink for each of the
supported versions of Ruby and `bundle install` all dependencies.

With the supported versions of Ruby installed RVM will run specs across
all version with just one command.

    bundle exec rvm 1.8.6@hoodwink,ree@hoodwink,1.8.7@hoodwink,1.9.2@hoodwink,jruby@hoodwink rspec spec/**/*_spec.rb

This command is wrapped up in to a rake task and can be invoked like so:

    rake spec:rubies
