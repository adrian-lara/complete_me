#!/usr/bin/env rake
require "rake/testtask"

Rake::TestTask.new do |t|
  ENV['run_long_tests'] = (ARGV.include? 'full').to_s
  t.libs << "test"
  t.test_files = FileList['test/*.rb']
  t.verbose = true
end
