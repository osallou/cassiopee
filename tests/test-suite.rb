$:.unshift '../lib'
require 'cassiopee'
require 'cassiopee-mt'
#require File.join(File.dirname(__FILE__), '../lib/cassiopee')
#require File.join(File.dirname(__FILE__), '../lib/cassiopee-mt')
require 'logger'
require 'test/unit'

class TestCrawler < Test::Unit::TestCase

 
  def test_exactsearch
    crawler = Cassiopee::Crawler.new
    #crawler.setLogLevel(Logger::DEBUG)
    crawler.indexString('my sample example')
    matches = crawler.searchExact('ampl')
    assert_equal(2,matches.length)
    # Minus 1, because first element is len of match
    #match = crawler.next()
    #assert_equal(2,match[2].length-1)
  end

  def test_exactsearch2
    crawler = Cassiopee::Crawler.new
    crawler.indexString('my sample example')
    matches = crawler.searchExact('xample')
    assert_equal(1,matches.length)
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


  def test_suffixmethod
    crawler = Cassiopee::Crawler.new
    crawler.method = Cassiopee::Crawler::METHOD_SUFFIX
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

  def test_cache

    crawler = Cassiopee::Crawler.new
    crawler.indexString('my sample example')
    matches = crawler.searchApproximate('ebampl',-1)

    cache = Cassiopee::CrawlerCache.new
    cache.method = 2
    cache.min_position = 0
    cache.max_position = 0
    cache.errors = 1
    cache.saveCache(matches)

    cache = Cassiopee::CrawlerCache.new
    cache.method = 2
    cache.min_position = 0
    cache.max_position = 0
    cache.errors = 1
    cachematches = cache.loadCache
    assert_equal(1,cachematches.length)

    cache = Cassiopee::CrawlerCache.new
    cache.method = 2
    cache.min_position = 0
    cache.max_position = 0
    cache.errors = 2
    cachematches = cache.loadCache
    assert_equal(0,cachematches.length)

  end
end



