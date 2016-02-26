require 'rake'
require 'rake/testtask'

$LOAD_PATH.unshift File.expand_path("../lib", __FILE__)

desc 'run test suite'
Rake::TestTask.new do |t|
  t.libs << '.' << 'lib' << 'test'
  t.test_files = FileList['test/*_test.rb']
  t.verbose = false
end

task :console do
  exec 'irb -I . -r hamlish_liquid'
end