require File.join(File.dirname(__FILE__), 'lib/cassiopee')
require 'rubygems'
require 'logger'

crawler = Cassiopee::Crawler.new
crawler.indexString('sallou')
crawler.searchExact('llo')


test= "my string"
test.extend(Cassiopee)
test.computeDistance('test',0,0)
puts "Hamming: " << test.computeHamming("my strigg",1).to_s

puts "LEVENSHTEIN: " << test.computeEdit("mystriigg",3).to_s
