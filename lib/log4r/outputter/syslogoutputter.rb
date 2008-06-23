# :include: ../rdoc/syslogoutputter
#
# Version:: $Id: syslogoutputter.rb,v 1.5 2004/03/17 20:18:00 fando Exp $
# Author:: Steve Lumos
# Author:: Leon Torres

begin
require 'syslog'

module Log4r

  class SyslogOutputter < Outputter
    include Syslog::Constants

    # This is the mapping of syslog levels to integers
    #(7 = debug, 6 = info, 5 = notice, 4 = warning, 3 = err, 2 = crit, 1 = alert, 0 = emerg, x = nothing)
    
    SYSLOG_LOGGER_MAP = {
      0 => LOG_DEBUG,
      1 => LOG_DEBUG,
      2 => LOG_INFO,
      3 => LOG_WARNING,
      4 => LOG_ERR,
      5 => LOG_CRIT,
      6 => LOG_CRIT
    } 

    # There are 3 hash arguments
    #
    # [<tt>:ident</tt>]     syslog ident, defaults to _name
    # [<tt>:logopt</tt>]    syslog logopt, defaults to LOG_PID | LOG_CONS
    # [<tt>:facility</tt>]  syslog facility, defaults to LOG_USER
    def initialize(_name, hash={})
      super(_name, hash)
      ident = (hash[:ident] or _name)
      logopt = (hash[:logopt] or LOG_PID | LOG_CONS).to_i
      facility = Syslog::Constants.const_get(hash[:facility]) if hash[:facility] != nil and  Syslog::Constants.const_defined?(hash[:facility])
      facility ||= Syslog::LOG_LOCAL0
      @syslog = Syslog.open(ident, logopt, facility)
    end

    def closed?
      return !@syslog.opened?
    end
    
    def close
      @syslog.close unless @syslog.nil?
      @level = OFF
      OutputterFactory.create_methods(self)
      Logger.log_internal {"Outputter '#{@name}' closed Syslog and set to OFF"}
    end

    private

    def canonical_log(logevent)
      pri = SYSLOG_LOGGER_MAP[logevent.level]
      o = logevent.data
      msg = format(logevent)
      @syslog.log(pri, '%s', msg)
    end
  end
end

rescue Exception => detail
  module Log4r
    class SyslogOutputter < Outputter
      def initialize(_name, hash={})
        super(_name, hash)    
      end
      
      ##########
      # constants from syslog.c, just bogus values for windows
      LOG_PID = 0
      LOG_CONS = 1
      LOG_ODELAY = 2
      LOG_NDELAY = 3
      LOG_NOWAIT = 4
      LOG_PERROR = 5
      LOG_AUTH = 6
      LOG_AUTHPRIV = 7
      LOG_CONSOLE = 8
      LOG_CRON = 9
      LOG_DAEMON = 10
      LOG_FTP = 11
      LOG_KERN = 12
      LOG_LPR = 13
      LOG_MAIL = 14
      LOG_NEWS = 15
      LOG_NTP = 16
      LOG_SECURITY = 17
      LOG_SYSLOG = 18
      LOG_USER = 19
      LOG_UUCP = 20
      LOG_LOCAL0 = 21
      LOG_LOCAL1 = 22
      LOG_LOCAL2 = 23
      LOG_LOCAL3 = 24
      LOG_LOCAL4 = 25
      LOG_LOCAL5 = 26
      LOG_LOCAL6 = 27
      LOG_LOCAL7 = 28
      LOG_EMERG = 29
      LOG_ALERT = 30
      LOG_CRIT = 31
      LOG_ERR = 32
      LOG_WARNING = 33
      LOG_NOTICE = 34
      LOG_INFO = 35
      LOG_DEBUG = 36
      
      
      def closed?
        @level == OFF
      end
    
      def close
        @level = OFF
        OutputterFactory.create_methods(self)
      end
    end
  end
end
