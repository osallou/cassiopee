require 'digest/md5'
require 'logger'
require 'zlib'

module Cassiopee

    class Crawler
 
    attr_accessor  :curpage, :resultPerPage, :useAmbiguity, :file_suffix
    
    FILE_SUFFIX_EXT = ".sfx"
    FILE_SUFFIX_POS = ".sfp"
    
    $log = Logger.new(STDOUT)
    $log.level = Logger::DEBUG
    
        def initialize
            @curpage = 0
            @resultPerPage = 100
            @useAmbiguity = false
            @file_suffix = "crawler"
            
            @suffix = nil
            @suffixmd5 = nil
            @position = 0
            
            @suffixes = Hash.new
        end
    
        def setLogLevel(level)
            $log.level = level
        end
        
        def indexFile(f)
         # Parse file, map letters to reduced alphabet
         # Later on, use binary map instead of ascii map
         # Take all suffix, order by length, link to position map on other file
         # Store md5 for easier compare? + 20 bytes per suffix
            sequence2index = readSequence(f)
            parseSuffixes(sequence2index)
        end
        
        def indexString(s)
            parseSuffixes(s)
        end
        
        def searchExact(s)
         # Search required length, compare (compare md5?)
         # MD5 = 128 bits, easier to compare for large strings
            @suffixes = loadSuffixes(@file_suffix+FILE_SUFFIX_POS)
            matchsize = s.length
            matchmd5 = Digest::MD5.hexdigest
            @suffixes.each do |md5val,posArray|
                if (k == matchmd5)
                    puts posArray.to_s
                end
            end
         
        
        end
        
        def searchApproximate(s,hamming,edit)
        
        end
        
        def next
        
        end
        
        def to_s
        
        end
        
        private
        
            def parseSuffixes(s)
                File.delete(@file_suffix+FILE_SUFFIX_EXT)
                File.delete(@file_suffix+FILE_SUFFIX_POS)
                (s.length).downto(1)  do |i|
                    (0..(s.length-i)).each do |j|
                        @suffix = s[j,i]
                        @suffixmd5 = Digest::MD5.hexdigest(@suffix)
                        @position = j
                        $log.debug("add "+@suffix+" at pos "+@position.to_s)
                        if(@suffixes.has_key?(@suffixmd5))
                            # Add position
                            @suffixes[@suffixmd5] << @position
                        else
                            # Add position, write new suffix
                            # First elt is size of elt
                            @suffixes[@suffixmd5] = Array[i, @position]
                            File.open(@file_suffix+FILE_SUFFIX_EXT, 'a') {|f| f.write(@suffixmd5+"\n"+@suffix+"\n") }
                        end
                    end
                end
                marshal_dump = Marshal.dump(@suffixes)
                sfxpos = File.new(@file_suffix+FILE_SUFFIX_POS,'w')
                sfxpos = Zlib::GzipWriter.new(sfxpos)
                sfxpos.write marshal_dump
                sfxpos.close
            end
          
            def readSequence(s)
                 counter = 1
                 sequence = ''
                    begin
                        file = File.new(s, "r")
                    	while (line = file.gets)
                    		counter = counter + 1
                            sequence << line.chomp
                    	end
                    	file.close
                    rescue => err
                    	puts "Exception: #{err}"
                    	err
                    end
                    return sequence
             end
             
             
            def loadSuffixes(file_name)
                begin
                  file = Zlib::GzipReader.open(file_name)
                rescue Zlib::GzipFile::Error
                  file = File.open(file_name, 'r')
                ensure
                    obj = Marshal.load file.read
                    file.close
                    return obj
                end
            end
             
             
             
    end

end