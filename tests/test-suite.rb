require File.join(File.dirname(__FILE__), '../lib/cassiopee')
require 'rubygems'
require 'logger'
require 'test/unit'

class TestCrawler < Test::Unit::TestCase

  def test_exactsearch
    crawler = Cassiopee::Crawler.new
    crawler.setLogLevel(Logger::ERROR)
    crawler.indexString('my sample example')
    matches = crawler.searchExact('ampl')
    assert_equal(1,matches.length)
    # Minus 1, because first element is len of match
    match = crawler.next()
    assert_equal(2,match[2].length-1)
  end

end



