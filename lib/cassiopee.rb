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
       return computeLevenshtein(pattern,edit)
      end
    end
    
    # Calculate number of substitution between string and pattern
    # Extend a String
    # Return -1 if max is reached
    
    def computeHamming(pattern,hamming)
    	pattern = pattern.downcase
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
    
    def computeLevenshtein(pattern,edit)
    	pattern = pattern.downcase
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
 
 	# Use alphabet ambiguity (dna/rna) in search
    attr_accessor  :useAmbiguity
    # Suffix files name/path
    attr_accessor  :file_suffix
    # Max number fo threads to use (not yet used)
    attr_accessor  :maxthread
    # Use persistent suffix file ?
    attr_accessor  :use_store
    
    FILE_SUFFIX_EXT = ".sfx"
    FILE_SUFFIX_POS = ".sfp"
    
    SUFFIXLEN = 'suffix_length'

    $maxthread = 1
    
    $log = Logger.new(STDOUT)
    $log.level = Logger::DEBUG
    
        def initialize
            @useAmbiguity = false
            @file_suffix = "crawler"
            
            @suffix = nil
            @suffixmd5 = nil
            @position = 0
            
            @suffixes = Hash.new
            
            @matches = nil
            @curmatch = 0
            @use_store = false
            
            @sequence = nil
        end
        
        # Clear suffixes in memory
        
        def clear
        	@suffixes = Hash.new
        end
    
    	# Set Logger level
    
        def setLogLevel(level)
            $log.level = level
        end
        
        # Index an input file
        
        def indexFile(f)
         # Parse file, map letters to reduced alphabet
         # Later on, use binary map instead of ascii map
         # Take all suffix, order by length, link to position map on other file
         # Store md5 for easier compare? + 20 bytes per suffix
            @sequence = readSequence(f)
            
        end
        
        # Index an input string
        
        def indexString(s)
            @sequence = s
            File.open(@file_suffix+FILE_SUFFIX_EXT, 'w') do |data|
            	data.puts(@sequence)
            end
            
            
        end
        
        # Search exact match
        
        def searchExact(pattern)
        pattern = pattern.downcase
        parseSuffixes(@sequence,pattern.length,pattern.length)
        
         @matches = Array.new
         # Search required length, compare (compare md5?)
         # MD5 = 128 bits, easier to compare for large strings
            matchsize = pattern.length
            matchmd5 = Digest::MD5.hexdigest(pattern)
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
        	parseSuffixes(@sequence,s.length-edit,s.length+edit)
        
        	
            minmatchsize = s.length - edit
            maxmatchsize = s.length + edit
            matchmd5 = Digest::MD5.hexdigest(s)
            
        	@matches = Array.new
        	
        	@suffixes.each do |md5val,posArray|
        		if(md5val == SUFFIXLEN)
        			next
        		end
        		if (md5val == matchmd5)
                    match = Array[md5val, 0, posArray]
		    		$log.debug "Match: " << match.inspect
		    		@matches << match
		    	else
		    		if(posArray[0]>= minmatchsize && posArray[0] <= maxmatchsize)
		    			# Get string
		    			seq = extractSuffix(posArray[1],posArray[0])
		    			seq.extend(Cassiopee)
		    			errors = seq.computeLevenshtein(s,edit)
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
        
        def extractSuffix(start,len)
        	sequence = ''
                begin
                	file = File.new(@file_suffix+FILE_SUFFIX_EXT, "r")
		    		file.pos = start
					sequence = file.read(len)
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
        	
            def parseSuffixes(s,minlen,maxlen)
            
            # Controls
            if(minlen<=0) 
            	minlen = 1
            end
            if(maxlen>@sequence.length)
            	maxlen = @sequence.length
            end
            
            
            	suffixlen = nil
            	$log.info('Start indexing')
            	loaded = false
            	# Hash in memory already contain suffixes for searched lengths
            	if(@suffixes != nil && !@suffixes.empty?)
            		suffixlen = @suffixes[SUFFIXLEN]
            		if(suffixlen!=nil && !suffixlen.empty?)
            			loaded = true
            			(maxlen).downto(minlen)  do |len|
            				if(suffixlen.index(len)==nil)
            					loaded = false
            					break
            				end
            			end
            		end
            	end
            	
            	if(@use_store && loaded)
            		$log.debug('already in memory, skip file loading')
            	end
            	
            	# If not already in memory
            	if(@use_store && !loaded)
            		@suffixes = loadSuffixes(@file_suffix+FILE_SUFFIX_POS)
            		suffixlen = @suffixes[SUFFIXLEN]
            	end
            	
            	nbSuffix = 0
                changed = false
                
                # Load suffix between maxlen and minlen
                (maxlen).downto(minlen)  do |i|
                	$log.debug('parse for length ' << i.to_s)
                	if(suffixlen!=nil && suffixlen.index(i)!=nil)
                		$log.debug('length '<<i <<'already parsed')
                		next
                	end
                	changed = true
               		 (0..(s.length-maxlen)).each do |j|
                    	@suffix = s[j,i]
                    	@suffixmd5 = Digest::MD5.hexdigest(@suffix)
                    	@position = j
                    	#$log.debug("add "+@suffix+" at pos "+@position.to_s)
                    	nbSuffix += addSuffix(@suffixmd5, @position,i)
                    end
                    $log.debug("Nb suffix found: " << nbSuffix.to_s << ' for length ' << i.to_s)
                end
            
                
                if(@use_store && changed)
                	$log.info("Store suffixes")
                	marshal_dump = Marshal.dump(@suffixes)
                	sfxpos = File.new(@file_suffix+FILE_SUFFIX_POS,'w')
                	sfxpos = Zlib::GzipWriter.new(sfxpos)
                	sfxpos.write marshal_dump
                	sfxpos.close
                end
                $log.info('End of indexing')
            end
          
          
          	# Add a suffix in Hashmap
          	
          	def addSuffix(md5val,position,len)
          		if(@suffixes.has_key?(md5val))
                    # Add position
                	@suffixes[md5val] << position
    	        else
                    # Add position, write new suffix
                    # First elt is size of elt
                	@suffixes[md5val] = Array[len, position]
                	if(@suffixes.has_key?(SUFFIXLEN))
                		@suffixes[SUFFIXLEN] << len
                	else
                		@suffixes[SUFFIXLEN] = Array[len]
                	end
                end
          		return 1
          	end
          
          	# read input string, and concat content
          	
            def readSequence(s)
            	$log.debug('read input sequence')
                 counter = 1
                 sequence = ''
                    begin
                        file = File.new(s, "r")
                        File.delete(@file_suffix+FILE_SUFFIX_EXT) unless !File.exists?(@file_suffix+FILE_SUFFIX_EXT)
						File.open(@file_suffix+FILE_SUFFIX_EXT, 'w') do |data|
                    	  while (line = file.gets)
                    			counter = counter + 1
                            	input = line.downcase.chomp
								sequence << input
								data.puts input
                    	  end
                    	
						end
                    	file.close
                    rescue => err
                    	puts "Exception: #{err}"
                    	err
                    end
                    $log.debug('data file created')
                    return sequence
             end
             
            # Load suffix position file in memory 
            
            def loadSuffixes(file_name)
            	return Hash.new unless File.exists?(@file_suffix+FILE_SUFFIX_POS)
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
