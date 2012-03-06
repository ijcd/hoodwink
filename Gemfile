source "http://rubygems.org"

# Specify your gem's dependencies in hoodwink.gemspec
gemspec

group :development, :test do
  gem 'ruby-debug', :platforms => :ruby_18
  gem 'ruby-debug19', :platforms => :ruby_19
end

# TODO: fix supermodel dependency on activemodel ~> 3.0.0 so we can move this to gemspec
gem 'supermodel', :path => '~/work/github/supermodel'

group :development do
  #gem 'ruby_gntp'
  #gem 'growl'
end
