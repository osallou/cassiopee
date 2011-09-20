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

    MINSEQSIZE=10 
 
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
    end

   def searchExact(pattern)
        len = @sequence.length
        if(@min_position>0)
          min = @min_position
         else
          min = 0  
        end
         if(@max_position>0)
           max = @max_position
         else
           max= @sequence.length
        end
        len = max - min 
        if(len<MINSEQSIZE)
              @maxthread=1
        end
        nb = len.div(maxthread)
        (1..maxthread).each do |i|
			crawler = Crawler.new
			setParams(crawler,i)
			curmax = min + nb
			if(i==maxthread)
				curmax = max
			end
			crawler.filter_position(min,curmax)
			$log.debug("Start new Thread between " << min.to_s << " and " << curmax.to_s)
			@th[i-1] = Thread.new{ Thread.current["matches"] = crawler.searchExact(pattern) }
			min = curmax + 1
        end
        @th.each {|t| t.join; t["matches"].each { |m| @matches << m }}
        return @matches
   end

   def searchApproximate(s,edit)
        len = @sequence.length
        if(@min_position>0)
          min = @min_position
         else
          min = 0 
        end
         if(@max_position>0)
           max = @max_position
         else
           max = @sequence.length
        end
        len = max - min
        if(len<MINSEQSIZE)
              @maxthread=1
        end
        nb = len.div(maxthread)
        (1..maxthread).each do |i|
          crawler = Crawler.new
          setParams(crawler,i)
          curmax = min + nb
          if(i==maxthread)
             curmax = max
          end
          crawler.filter_position(min,curmax)
          $log.debug("Start new Thread between " << min.to_s << " and " << curmax.to_s)
          @th[i-1] = Thread.new{ Thread.current["matches"] = crawler.searchApproximate(s,edit) }
          min = curmax + 1
        end
        @th.each {|t| t.join; t["matches"].each { |m| @matches << m }}
        return @matches
   end 

   end

end
