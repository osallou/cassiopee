Gem::Specification.new do |s|
  s.name = %q{cassiopee}
  s.version = "0.1.1"
  s.date = %q{2011-09-04}
  s.authors = ["Olivier Sallou"]
  s.email = %q{olivier.sallou@gmail.com}
  s.summary = %q{Cassiopee index strings and provide exact or approximate search.}
  s.homepage = %q{https://github.com/osallou/cassiopee}
  s.description = %q{Cassiopee index one String and provide methods to search exact match or approximate matches with Hammming and/or edit distance.}
  s.files = [ "README", "Changelog", "LICENSE", "demo.rb", "lib/cassiopee.rb"]
  s.has_rdoc = true
  s.rdoc_options << '--main lib/cassiopee.rb'
  s.license = 'LGPL-3'
  s.test_file = 'tests/test-suite.rb'
  s.add_dependency('text', '>= 0.2.0')
  s.add_dependency('rubygems')
end
