require 'rake'

task default: [:rubocop, :test]

task :rubocop do
    require 'rubocop/rake_task'
    RuboCop::RakeTask.new
end

task :test do
    sh 'ruby test.rb'
end