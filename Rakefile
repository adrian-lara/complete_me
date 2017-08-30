#!/usr/bin/env rake
require "rake/testtask"

Rake::TestTask.new do |t|

  if ARGV.include?('full')
    ENV['run_long_tests'] = 'true'
    t.verbose = true
    task :full do end
  end

  t.libs << "test"
  t.test_files = FileList['test/*.rb']

end
