module Cassiopee

    class Crawler
 
    attr_accessor  :curpage, :resultPerPage, :useAmbiguity
    
        def initialize
            @curpage = 0
            @resultPerPage = 100
            @useAmbiguity = false
        end
    
        
        def index(f)
         # Parse file, map letters to reduced alphabet
         # Later on, use binary map instead of ascii map
         # Take all suffix, order by length, link to position map on other file
         # Store md5 for easier compare? + 20 bytes per suffix
         sequence2index = readSequence(f)
            
        
        end
        
        def searchExact(s)
         # Search required length, compare (compare md5?)
         # MD5 = 128 bits, easier to compare for large strings
         
        
        end
        
        def searchApproximate(s,hamming,edit)
        
        end
        
        def next
        
        end
        
        def to_s
        
        end
        
        private
        
         def readSequence(s)
         counter = 1
         sequence = ''
            begin
                file = File.new(s, "r")
            	while (line = file.gets)
            		puts "#{counter}: #{line}"
            		counter = counter + 1
                    sequence += #{line}.chomp
            	end
            	file.close
            rescue => err
            	puts "Exception: #{err}"
            	err
            end
            return sequence
         end
    end

end