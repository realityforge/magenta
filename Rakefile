require 'rake'
require 'spec/rake/spectask'

desc "Run all spec tests"
Spec::Rake::SpecTask.new('test:specs') do |t|
  t.spec_files = FileList['test/specs/**/*_spec.rb']
end

task :default => ['test:specs']