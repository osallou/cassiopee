require File.join(File.dirname(__FILE__), '../lib/cassiopee')
require File.join(File.dirname(__FILE__), '../lib/cassiopee-mt')
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

  def test_ambiguous 
    crawler = Cassiopee::Crawler.new
    crawler.loadAmbiguityFile(File.join(File.dirname(__FILE__), 'amb.map'))
    crawler.indexString('aaaaaaaaaaacgttttttt')
    matches = crawler.searchExact('aucgt')
    assert_equal(1,matches.length)
  end


  def test_hammingsearch
    crawler = Cassiopee::Crawler.new
    crawler.indexString('my sample example')
    matches = crawler.searchApproximate('ebampl',1)
    assert_equal(1,matches.length)
  end

  def test_levenshteinsearch
    crawler = Cassiopee::Crawler.new
    crawler.indexString('my sample example')
    matches = crawler.searchApproximate('ebampl',-1)
    assert_equal(1,matches.length)
  end

  def test_directmethod
    crawler = Cassiopee::Crawler.new
    crawler.method = Cassiopee::Crawler::METHOD_DIRECT
    crawler.indexString('my sample example')
    matches = crawler.searchApproximate('ebampl',1)
    assert_equal(1,matches.length)
  end

  def  test_multithreadsearch
    crawler = CassiopeeMt::CrawlerMt.new
    crawler.maxthread=3
    crawler.indexString('iiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiimy sample exampleiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiii')
    matches = crawler.searchExact('exam')
    assert_equal(1,matches.length)
  end

end



