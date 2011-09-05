require 'digest/md5'
require 'logger'
require 'zlib'

module Cassiopee

	# Calculate the edit or hamming distance between String and pattern
    # Extend a String
    # Return -1 if max is reached
    
    def computeDistance(pattern,hamming,edit)
      if(edit==0)
      	return computeHamming(pattern,hamming)
      else
       return computeEdit(pattern,edit)
      end
    end
    
    # Calculate number of substitution between string and pattern
    # Extend a String
    # Return -1 if max is reached
    
    def computeHamming(pattern,hamming)
    	nberr = 0
    	(0..(self.length-1)).each do |c|
    		if(pattern[c] != self[c])
    			nberr = nberr+1
    			if(nberr>hamming.to_i)
    				return -1		
    			end
    		end
    	end
    	return nberr
    end
    
    # Calculate the edit distance between string and pattern
    # Extend a String
    # Return -1 if max is reached
    
    def computeEdit(pattern,edit)
    	matrix= Array.new(2)
    	matrix[0] = Array.new(pattern.length+1)
    	matrix[1] = Array.new(pattern.length+1)
    	(0..(pattern.length)).each do |i|
    		matrix[0][i]=i
    		matrix[1][i]=i
    	end
    	c=0
    	p=1
    	(1..(self.length)).each do |i|
    		c = i.modulo(2)
    		p = (i+1).modulo(2)
    		matrix[c][0] = i
        	(1..(pattern.length)).each do |j|
        		# Bellman's principle of optimality
        		weight = 0
    			if(pattern[i-1] != self[j-1])
    					weight = 1
    			end
    			weight = matrix[p][j-1] + weight
    			if(weight > matrix[p][j] +1)
    				weight = matrix[p][j] +1
    			end
    			if(weight > matrix[c][j-1] +1)
    				weight = matrix[c][j-1] +1
    			end
    			matrix[c][j] = weight
    		end	
    	end
    	p = c
    	c = (c + 1).modulo(2)
    	if(matrix[p][pattern.length]>edit)
    		return -1
    	end
    	return matrix[p][pattern.length]
    	
    end
 
 	# Base class to index and search through a string 
 
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
            
            @matches = nil
            @curmatch = 0
        end
    
        def setLogLevel(level)
            $log.level = level
        end
        
        # Index an input file
        
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
        
        # Search exact match
        
        def searchExact(s)
         @matches = Array.new
         # Search required length, compare (compare md5?)
         # MD5 = 128 bits, easier to compare for large strings
            @suffixes = loadSuffixes(@file_suffix+FILE_SUFFIX_POS)
            matchsize = s.length
            matchmd5 = Digest::MD5.hexdigest(s)
            @suffixes.each do |md5val,posArray|
                if (md5val == matchmd5)
                    match = Array[md5val, 0, posArray]
		    		$log.debug "Match: " << match.inspect
		    		@matches << match
                end
            end
        return @matches 
        
        end
        
        # Search an approximate string
        #
        # * support insertion, deletion, substitution
        
        
        def searchApproximate(s,edit)
        	if(edit==0) 
        		return searchExact(s)
        	end
        
        	@suffixes = loadSuffixes(@file_suffix+FILE_SUFFIX_POS)
            minmatchsize = s.length - edit
            maxmatchsize = s.length + edit
            matchmd5 = Digest::MD5.hexdigest(s)
            
        	@matches = Array.new
        	
        	@suffixes.each do |md5val,posArray|
        		if (md5val == matchmd5)
                    match = Array[md5val, 0, posArray]
		    		$log.debug "Match: " << match.inspect
		    		@matches << match
		    	else
		    		if(posArray[0]>= minmatchsize && posArray[0] <= maxmatchsize)
		    			# Get string
		    			seq = extractSuffix(md5val)
		    			seq.extend(Cassiopee)
		    			errors = seq.computeEdit(s,edit)
		    			if(errors>=0)
		    			    match = Array[md5val, errors, posArray]
		    				$log.debug "Match: " << match.inspect
		    				@matches << match
		    			end
		    		end
                end
        	
        	end
        	
        	return @matches 
        end
        
        # Extract un suffix from suffix file based on md5 match
        
        def extractSuffix(md5val)
        	sequence = ''
                begin
                    file = File.new(@file_suffix+FILE_SUFFIX_EXT, "r")
                	while (line = file.gets)
						if(line.chomp == md5val)
							line = file.gets
                        	sequence << line.chomp
                        	break
                        else
                        	line = file.gets
                        end
                    end
                	file.close
                rescue => err
                	puts "Exception: #{err}"
                	return nil
                end
        	return sequence
        end
        
        # Iterates over matches
        
        def next
        	if(@curmatch<@matches.length)
        		@curmatch = @curmatch + 1
        		return @matches[@curmatch-1]
        	else
        		@curmatch = 0
        		return nil
        	end
        end
        
        def to_s
        	puts '{ matches: "' << @matches.length << '" }'
        end
        
        private
        
        	# Parse input string
        	#
        	# * creates a suffix file
        	# * creates a suffix position file
        	
            def parseSuffixes(s)
                File.delete(@file_suffix+FILE_SUFFIX_EXT) unless !File.exists?(@file_suffix+FILE_SUFFIX_EXT)
                File.delete(@file_suffix+FILE_SUFFIX_POS) unless !File.exists?(@file_suffix+FILE_SUFFIX_POS)
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
          
          	# read input string, and concat content
          	
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
             
            # Load suffix position file in memory 
            
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
