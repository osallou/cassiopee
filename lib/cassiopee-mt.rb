require 'digest/md5'
require 'logger'
require 'zlib'
#require 'rubygems'
#require 'text'
#require 'text/util'
require File.join(File.dirname(__FILE__), 'cassiopee')

include Cassiopee

# Module managing multi threads to search in strings, extending Cassiopee
module CassiopeeMt

    # Multi threaded search using a Crawler per thread
    # Filtering is used to split the input data according to maxthread
    # Matches of each thread are merge to matches of CrawlerMT
    class CrawlerMt < Crawler
 
    # Max number fo threads to use
    attr_accessor  :maxthread

    @th = []

    def initialize
	super
	@th = []
	@matches = Array.new
    end


    def setParams(crawler,threadId)
      crawler.setLogLevel($log.level)
      crawler.file_suffix = @file_suffix
      crawler.loadIndex()
      #crawler.file_suffix = @file_suffix+"."+threadId.to_s
      crawler.indexString(@sequence)
    end

   def searchExact(pattern)
        nb = @sequence.length.div(maxthread)
        min = 0
        (1..maxthread).each do |i|
          crawler = Crawler.new
	  setParams(crawler,i)
          max = min + nb
          if(i==maxthread)
             max = @sequence.length
          end
          crawler.filter_position(min,max)
	  $log.debug("Start new Thread between " << min.to_s << " and " << max.to_s)
          @th[i-1] = Thread.new{ Thread.current["matches"] = crawler.searchExact(pattern) }
          min = max + 1
        end
        @th.each {|t| t.join; t["matches"].each { |m| @matches << m }}
        return @matches
   end

   def searchApproximate(s,edit)
        nb = @sequence.length.div(maxthread)
        min = 0
        (1..maxthread).each do |i|
          crawler = Crawler.new
          setParams(crawler,i)
          max = min + nb
          if(i==maxthread)
             max = @sequence.length
          end
          crawler.filter_position(min,max)
          $log.debug("Start new Thread between " << min.to_s << " and " << max.to_s)
          @th[i-1] = Thread.new{ Thread.current["matches"] = crawler.searchApproximate(s,edit) }
          min = max + 1
        end
        @th.each {|t| t.join; t["matches"].each { |m| @matches << m }}
        return @matches
   end 

   end

end
