require "bundler/gem_tasks"
Bundler.setup

require "rspec/core/rake_task"
RSpec::Core::RakeTask.new(:spec) do |t|
  t.rspec_opts = "--format RSpec::Formatters::IllustratedDocumentationFormatter"
end

task :list_undoc do
  sh 'yard stats --list-undoc'
end

task :sanity_check => [:spec, :list_undoc]
task :test => :spec
task :default => :spec
