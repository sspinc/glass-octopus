require "bundler/gem_tasks"
require "rake/testtask"

Rake::TestTask.new do |t|
  t.libs << "test"
  t.pattern = "test/**/*_test.rb"
  t.verbose = ENV.key?("VERBOSE")
  t.warning = false
end

task :default => :test
