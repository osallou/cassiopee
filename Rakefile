require 'rake/testtask'

Rake::TestTask.new do |t|
  t.libs << ["lib", "tests"]
  t.test_files = FileList['tests/test*.rb']
  t.verbose = true
end
