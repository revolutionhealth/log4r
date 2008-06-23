require File.dirname(__FILE__) + '/test_helper'

module Log4r
  class RollingFileOutputter
    public
    attr_accessor :out_filename, :rolled

    alias_method :roll_orig, :roll
    def roll
      begin
        @out.close
      rescue 
        Logger.log_internal {
          "RollingFileOutputter '#{@name}' could not close #{@filename}"
        }
      end
      @count += 1

      @out_filename = @filename
      raise "Should have asserted and reset this!" if @rolled != nil and @rolled == true
      @rolled = true
      @out = StringIO.new
    end 
  end
end


class TestLog4r < Test::Unit::TestCase
  include Log4r
  
  def test_roller
    sizeLog = Logger.new 'WbExplorer'
    rolling_appender = RollingFileOutputter.new("WbExplorer", { "filename" => file_path("TestSize.log"), "maxsize" => 16000, "trunc" => true })
    sizeLog.outputters = rolling_appender
    sizeLog.level = DEBUG
    
    assert_equal file_path("TestSize.log.1"), rolling_appender.send(:indexed_filename, 1)
    assert_equal file_path("TestSize.log"), rolling_appender.instance_eval { @filename }

    #reset after initialization
    rolling_appender.rolled = false
    bytes_acc = 0
    first_roll = true

    10000.times do |t|
      bytes_acc += " INFO WbExplorer: blah #{t} ".size + 1
      sizeLog.info "blah #{t}"
      datasize = rolling_appender.instance_eval { @datasize }
      assert_equal bytes_acc, datasize if datasize != 0
      if (bytes_acc > 16000)
        assert rolling_appender.rolled 
        assert_equal 0, datasize
        
        bytes_acc = 0
        rolling_appender.rolled = false
      end
    end
  end
  
  def test_initial_roll
    FileUtils.rm(Dir.glob(file_path("TestInitialRoll.log*")))
    sizeLog = Logger.new 'WbExplorer'
    rolling_appender = RollingFileOutputter.new("WbExplorer", { "filename" => file_path("TestInitialRoll.log"), "maxsize" => "1", "trunc" => false })
    assert_equal false, rolling_appender.send(:file_size_requires_roll?)
    file = File.new(file_path('TestInitialRoll.log'), 'w')
    file.puts("asfdasdf1")
    file.close
    assert File.exists?(file_path('TestInitialRoll.log'))
    assert File.size?(file_path('TestInitialRoll.log')).to_i > 2
    assert rolling_appender.send(:file_size_requires_roll?)
    
    
    rolling_appender = RollingFileOutputter.new("WbExplorer2", { "filename" => file_path("TestInitialRoll.log"), "maxsize" => "10KB", "trunc" => false })
    assert_equal false, rolling_appender.send(:file_size_requires_roll?)
  end
  
  def test_maxsize
    sizeLog = Logger.new 'WbExplorer'
    rolling_appender = RollingFileOutputter.new("WbExplorer", { "filename" => file_path("TestSize.log"), "maxsize" => "10KB", "trunc" => true })
    assert_equal (10*1024), rolling_appender.instance_eval { @maxsize }
    
    rolling_appender = RollingFileOutputter.new("WbExplorer", { "filename" => file_path("TestSize.log"), "maxsize" => "10MB", "trunc" => true })
    assert_equal (10*1024*1024), rolling_appender.instance_eval { @maxsize }
    
    rolling_appender = RollingFileOutputter.new("WbExplorer", { "filename" => file_path("TestSize.log"), "maxsize" => "10GB", "trunc" => true })
    assert_equal (10*1024*1024*1024), rolling_appender.instance_eval { @maxsize }
  end
  
  def test_real_roller
    Log4r::RollingFileOutputter.class_eval {  alias_method :roll_test, :roll }
    Log4r::RollingFileOutputter.class_eval {  alias_method :roll, :roll_orig }

    FileUtils.rm(Dir.glob(file_path("TestSize.log*")))
    sizeLog = Logger.new 'WbExplorer'
    rolling_appender = RollingFileOutputter.new("WbExplorer", { "filename" => file_path("TestSize.log"), :maxBackupIndex => 5,"maxsize" => 16000, "trunc" => true })
    sizeLog.outputters = rolling_appender
    sizeLog.level = DEBUG

    10000.times do |t|
      sizeLog.info "blah #{t}"
    end

    Log4r::RollingFileOutputter.class_eval {  alias_method :roll_orig, :roll }
    Log4r::RollingFileOutputter.class_eval {  alias_method :roll, :roll_test }
  end
  
  def test_real_roller2
    Log4r::RollingFileOutputter.class_eval {  alias_method :roll_test, :roll }
    Log4r::RollingFileOutputter.class_eval {  alias_method :roll, :roll_orig }

    FileUtils.rm(Dir.glob(file_path("TestRollover.log.*")))
    sizeLog = Logger.new 'WbExplorer'
    rolling_appender = RollingFileOutputter.new("WbExplorer", { "filename" => file_path("TestRollover.log"), :maxBackupIndex => 5,"maxsize" => 16000, "trunc" => true })
    sizeLog.outputters = rolling_appender
    sizeLog.level = DEBUG
    
    sizeLog.info "blah 111"
    ((16000) / " INFO WbExplorer: blah 123\n\n".size).times do |x|
      sizeLog.info "blah 123"
    end
    sizeLog.info "blah 222"
    
    ((16000) / " INFO WbExplorer: blah 123\n\n".size).times do |x|
      sizeLog.info "blah 123"
    end
    sizeLog.info "blah 333"
        
    ((16000) / " INFO WbExplorer: blah 123\n\n".size).times do |x|
      sizeLog.info "blah 123"
    end
    sizeLog.info "blah 444"
    
    ((16000) / " INFO WbExplorer: blah 123\n\n".size).times do |x|
      sizeLog.info "blah 123"
    end
    sizeLog.info "blah 555"
    
    ((16000) / " INFO WbExplorer: blah 123\n\n".size).times do |x|
      sizeLog.info "blah 123"
    end
    
    ## just add a few to the last..
    ((16000) / (" INFO WbExplorer: blah 123\n\n".size * 2)).times do |x|
      sizeLog.info "blah 123"
    end
    sizeLog.info "blah 999"
    
    File.open(file_path('TestRollover.log.5')) {|f| assert_not_nil(f.read =~ /blah 111/) }
    File.open(file_path('TestRollover.log.4')) {|f| assert_not_nil(f.read =~ /blah 222/) }
    File.open(file_path('TestRollover.log.3')) {|f| assert_not_nil(f.read =~ /blah 333/) }
    File.open(file_path('TestRollover.log.2')) {|f| assert_not_nil(f.read =~ /blah 444/) }
    File.open(file_path('TestRollover.log.1')) {|f| assert_not_nil(f.read =~ /blah 555/) }
    File.open(file_path('TestRollover.log')) {|f| assert_not_nil(f.read =~ /blah 999/) }
    
    Log4r::RollingFileOutputter.class_eval {  alias_method :roll_orig, :roll }
    Log4r::RollingFileOutputter.class_eval {  alias_method :roll, :roll_test }
  end
  
  private
    def file_path(filename)
      File.join("#{RAILS_ROOT}", 'log', filename)
    end
end
