require "bundler/gem_tasks"

require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new('spec')

namespace :rvm do
  desc 'Run specs against 1.8.6, REE, 1.8.7, 1.9.2 and jRuby'
  task :specs do
    sh "rvm 1.8.6@webmock,ree@webmock,1.8.7@webmock,1.9.2@webmock,jruby@webmock exec rspec specs"
  end
end

# If you want to make this the default task
task :default => :spec

