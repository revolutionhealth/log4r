module Test
  module LogSqlPerTest

    def initialize(*args)
      super(*args)
      return unless wrap_methods = self.class.methods_to_log_sql_for
      dirname = "#{RAILS_ROOT}/log/#{self.class.to_s.underscore}"
      FileUtils.mkdir_p dirname unless File.directory? dirname
      wrap_methods = public_methods.grep(/^test_/) if wrap_methods.empty?
      (class << self; self; end).class_eval do
        wrap_methods.each do |name|
          name = name.to_s
          filename = File.join(dirname, name)
          outputter = Log4r::FileOutputter.new(name, :level => 0,
                                               :filename => filename)
          define_method(name) {
            color = ActiveRecord::Base.colorize_logging
            begin
              ActiveRecord::Base.colorize_logging = false
              ActiveRecord::Base.logger.outputters.push outputter
              super
            ensure
              ActiveRecord::Base.logger.outputters.delete outputter
              ActiveRecord::Base.colorize_logging = color
              outputter.close
            end
          }
        end
      end
    end

    def self.included(klass)
      class << klass
        attr_reader :methods_to_log_sql_for

        def log_sql_for(*wrap_methods)
          @methods_to_log_sql_for = wrap_methods
        end
      end
    end

  end
end  
