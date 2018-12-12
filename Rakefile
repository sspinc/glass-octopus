require "bundler/gem_tasks"
require "rake/testtask"

task :default => :test

Rake::TestTask.new do |t|
  t.libs << "test"
  t.pattern = "test/**/*_test.rb"
  t.verbose = ENV.key?("VERBOSE")
  t.warning = false
end

namespace :test do
  desc "Run all tests including integration tests"
  task :all do
    ENV["TEST_KAFKA_INTEGRATION"] = "yes"
    Rake::Task[:test].invoke
  end
end
