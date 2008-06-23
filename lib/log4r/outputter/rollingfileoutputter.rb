
# :nodoc:
# Version:: $Id: rollingfileoutputter.rb,v 1.4 2003/09/12 23:55:43 fando Exp $

require "log4r/outputter/fileoutputter"
require "log4r/staticlogger"

module Log4r

  # RollingFileOutputter - subclass of FileOutputter that rolls files on size
  # or time. Additional hash arguments are:
  #
  # [<tt>:maxsize</tt>]   Maximum size of the file in bytes.
  # [<tt>:trunc</tt>]	  Maximum age of the file in seconds.
  class RollingFileOutputter < FileOutputter

    attr_reader :count, :maxsize, :maxtime, :startTime, :maxBackupIndex #,i:baseFilename

    def initialize(_name, hash={})
      @count = 0
      @max_backup_index = 10
      super(_name, hash)
      set_maxsize(hash)
      if hash.has_key?(:maxtime) || hash.has_key?('maxtime') 
        _maxtime = (hash[:maxtime] or hash['maxtime']).to_i
        if _maxtime.class != Fixnum
          raise TypeError, "Argument 'maxtime' must be an Fixnum", caller
        end
        if _maxtime == 0
          raise TypeError, "Argument 'maxtime' must be > 0", caller
        end
        @maxtime = _maxtime
        @startTime = Time.now
      end
      if hash.has_key?(:maxBackupIndex) || hash.has_key?('maxBackupIndex')
        _max_backup_index = (hash[:maxBackupIndex] or hash['maxBackupIndex']).to_i
        if _max_backup_index.class != Fixnum
          raise TypeError, "Argument 'maxsize' must be an Fixnum", caller
        end
        if _max_backup_index == 0
          raise TypeError, "Argument 'maxsize' must be > 0", caller
        end
        @max_backup_index = _max_backup_index
      end
      @baseFilename = File.basename(@filename)
      # roll immediately so all files are of the form "000001-@baseFilename"
      roll if file_size_requires_roll?
      # initialize the file size counter
      @datasize = 0
    end

    #######
    private
    #######
    
    def set_maxsize(options) 
      if options.has_key?(:maxsize) || options.has_key?('maxsize')
        maxsize = (options[:maxsize] or options['maxsize'])

        multiplier = 1
        if (maxsize =~ /\d+KB/)
          multiplier = 1024
        elsif (maxsize =~ /\d+MB/)
          multiplier = 1024 * 1024
        elsif (maxsize =~ /\d+GB/)
          multiplier = 1024 * 1024 * 1024
        end
        
        _maxsize = maxsize.to_i * multiplier
        
        if _maxsize.class != Fixnum and _maxsize.class != Bignum
          raise TypeError, "Argument 'maxsize' must be an Fixnum", caller
        end
        if _maxsize == 0
          raise TypeError, "Argument 'maxsize' must be > 0", caller
        end
        @maxsize = _maxsize
      end
    end

    # perform the write
    def write(data) 
      # we have to keep track of the file size ourselves - File.size doesn't
      # seem to report the correct size when the size changes rapidly
      @datasize += data.size + 1 # the 1 is for newline
      super
      roll if requiresRoll
    end

    # construct a new filename from the count and baseFilname
    def makeNewFilename
      # note use of hard coded 6 digit counter width - is this enough files?
      pad = "0" * (6 - @count.to_s.length) + count.to_s
      newbase = @baseFilename.sub(/(\.\w*)$/, pad + '\1')
      @filename = File.join(File.dirname(@filename), newbase)
      Logger.log_internal {"File #{@filename} created"}
    end 

    # does the file require a roll?
    def requiresRoll
      if !@maxsize.nil? && @datasize > @maxsize
        @datasize = 0
        return true
      end
      if !@maxtime.nil? && (Time.now - @startTime) > @maxtime
        @startTime = Time.now
        return true
      end
      false
    end 
    
    def indexed_filename(index)
      @filename + ".#{index}"
    end

    # more expensive, only for startup
    def file_size_requires_roll?
      (@maxsize.to_i > 0 and (File.size?(@filename).to_i >= @maxsize.to_i))
    end
    
    # roll the file
    def roll
      begin
        @out.close
      rescue 
        Logger.log_internal {
          "RollingFileOutputter '#{@name}' could not close #{@filename}"
        }
      end
      @count += 1

      @max_backup_index.times do |x| 
        index = @max_backup_index - x - 1
        if File.exists?(indexed_filename(index)) and index != 0
          FileUtils.mv(indexed_filename(index), indexed_filename(index + 1))
        elsif index == 0 and File.exists?(@filename)
          FileUtils.mv(@filename, indexed_filename(index + 1))
        end
      end

      @out = File.new(@filename, (@trunc ? "w" : "a"))
    end 

  end

end

# this can be found in examples/fileroll.rb as well
if __FILE__ == $0
  require 'log4r'
  include Log4r


  timeLog = Logger.new 'WbExplorer'
  timeLog.outputters = RollingFileOutputter.new("WbExplorer", { "filename" => "TestTime.log", "maxtime" => 10, "trunc" => true })
  timeLog.level = DEBUG

  100.times { |t|
    timeLog.info "blah #{t}"
    sleep(1.0)
  }

  sizeLog = Logger.new 'WbExplorer'
  sizeLog.outputters = RollingFileOutputter.new("WbExplorer", { "filename" => "TestSize.log", "maxsize" => 16000, "trunc" => true })
  sizeLog.level = DEBUG

  10000.times { |t|
    sizeLog.info "blah #{t}"
  }

end
