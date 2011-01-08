require 'rubygems'
require 'rake'
require 'rake/testtask'
require 'rake/clean'
require 'rake/gempackagetask'

task :default => ['test']

spec = Gem::Specification.new do |s|
  s.name = "rubydbc"
  s.version = "1.0.0"
  s.author = "Martin Traverso"
  s.email = "mtraverso@acm.org"
  s.homepage = "http://rubyforge.org/projects/rubydbc"
  s.platform = Gem::Platform::RUBY
  s.summary = "A Design by Contract mixin for Ruby"
  s.files =  FileList["lib/*.rb"]
  s.require_path = "lib"
end

Rake::GemPackageTask.new(spec) do |pkg|
  pkg.need_tar = true
end

Rake::TestTask.new do |t|
  t.libs << "test"
  t.test_files = FileList['test/test*.rb']
  t.verbose = true
end

