# :include: log4r/rdoc/log4r
#
# == Other Info
#
# Author::      Leon Torres
# Version::     $Id: log4r.rb,v 1.10 2002/08/20 04:15:04 cepheus Exp $

require 'log4r/configurator'
require 'log4r/formatter/formatter'
require "log4r/formatter/patternformatter"
require "log4r/outputter/fileoutputter"
require "log4r/outputter/consoleoutputters"
require "log4r/outputter/staticoutputter"
require "log4r/outputter/rollingfileoutputter"
require "log4r/outputter/syslogoutputter"
require "log4r/loggerfactory"
require "test/log_sql_per_test.rb"

module Log4r
  Log4rVersion = [1, 0, 2].join '.'
end

if defined?(Rails)
  if Rails::VERSION::MAJOR < 2
    require 'rails_patch_for_migrations'
  end

  require 'log4r_logging'
end
