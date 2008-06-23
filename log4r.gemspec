Gem::Specification.new do |s|
  s.name = %q{log4r}
  s.version = "1.3.0"

  s.specification_version = 2 if s.respond_to? :specification_version=

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Revolution Health"]
  s.autorequire = %q{log4r}
  s.date = %q{2008-06-23}
  s.description = %q{Updated version of Log4r}
  s.email = %q{rails-trunk@revolutionhealth.com}
  s.extra_rdoc_files = ["README", "LICENSE", "TODO"]
  s.files = ["LICENSE", "README", "Rakefile", "TODO", "lib/log4r", "lib/log4r/base.rb", "lib/log4r/config.rb", "lib/log4r/configurator.rb", "lib/log4r/formatter", "lib/log4r/formatter/formatter.rb", "lib/log4r/formatter/patternformatter.rb", "lib/log4r/lib", "lib/log4r/lib/drbloader.rb", "lib/log4r/lib/xmlloader.rb", "lib/log4r/logevent.rb", "lib/log4r/logger.rb", "lib/log4r/loggerfactory.rb", "lib/log4r/logserver.rb", "lib/log4r/outputter", "lib/log4r/outputter/consoleoutputters.rb", "lib/log4r/outputter/datefileoutputter.rb", "lib/log4r/outputter/emailoutputter.rb", "lib/log4r/outputter/fileoutputter.rb", "lib/log4r/outputter/iooutputter.rb", "lib/log4r/outputter/outputter.rb", "lib/log4r/outputter/outputterfactory.rb", "lib/log4r/outputter/remoteoutputter.rb", "lib/log4r/outputter/rollingfileoutputter.rb", "lib/log4r/outputter/staticoutputter.rb", "lib/log4r/outputter/syslogoutputter.rb", "lib/log4r/repository.rb", "lib/log4r/staticlogger.rb", "lib/log4r/test", "lib/log4r/yamlconfigurator.rb", "lib/log4r.rb", "lib/log4r_logging.rb", "lib/rails_patch_for_migrations.rb", "lib/test", "lib/test/log_sql_per_test.rb", "test/log4r_test.rb", "test/orig_tests", "test/orig_tests/include.rb", "test/orig_tests/junk", "test/orig_tests/runtest.rb", "test/orig_tests/testbase.rb", "test/orig_tests/testcustom.rb", "test/orig_tests/testdefault.rb", "test/orig_tests/testformatter.rb", "test/orig_tests/testlogger.rb", "test/orig_tests/testoutputter.rb", "test/orig_tests/testpatternformatter.rb", "test/orig_tests/testxmlconf.rb", "test/orig_tests/xml", "test/orig_tests/xml/testconf.xml", "test/test_helper.rb"]
  s.has_rdoc = true
  s.homepage = %q{http://github.com/revolutionhealth/log4r/tree/master}
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.1.1}
  s.summary = %q{Updated version of Log4r}
end
