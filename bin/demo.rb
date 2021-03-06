#!/usr/bin/env ruby
$:.unshift '../lib'
require 'cassiopee'
require 'logger'

# Instantiate a new crawler
crawler = Cassiopee::Crawler.new
#crawler.use_store = true

# String to index
crawler.indexString('sallou sallu')
# Search pattern in indexed string
crawler.searchExact('llo')
# Search it again, using already loaded indexed data
crawler.searchExact('llo')


test= "my string"
# Extend to use match algorithms
test.extend(Cassiopee)
test.computeDistance('test',0,0)
puts "Hamming: " << test.computeHamming("my strigg",1).to_s

puts "Levenshtein: " << test.computeLevenshtein("mystriigg",3).to_s

# Approximate search, edit distance = 1
crawler.searchApproximate("llu",-2)

# Go through matches
while((match = crawler.next())!=nil)
  puts "got a match " << match.inspect
end
