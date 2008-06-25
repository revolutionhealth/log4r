
Log4r::Configurator['RAILS_ROOT'] = RAILS_ROOT
Log4r::Configurator['RAILS_ENV'] = RAILS_ENV

if defined?(ConfigurationLoader)
  Log4r::Configurator.load_xml_string(ConfigurationLoader.new(:optional_cache).load_raw_file('log4r.xml'))
elsif File.exists?(File.join(RAILS_ROOT, 'config', 'log4r.xml'))
  Log4r::Configurator.load_xml_file(File.join(RAILS_ROOT, 'config', 'log4r.xml'))
else
  Log4r::Configurator.load_xml_file(File.join(File.dirname(__FILE__), '..', '..', 'config', 'log4r.xml'))
end
  
silence_warnings {
	RAILS_DEFAULT_LOGGER = Log4r::Logger.get("#{RAILS_ENV}")
	RHG_METRICS_LOGGER = Log4r::Logger.get("#{RAILS_ENV}_metrics")
	METRICS_LOGGER = Log4r::Logger.get("#{RAILS_ENV}_metrics")
	ActiveRecord::Base.logger = Log4r::Logger.get("#{RAILS_ENV}_db")
	ActionController::Base.logger = RAILS_DEFAULT_LOGGER
}

Log4r::Logger.GDC = ((Pathname.new(RAILS_ROOT).cleanpath.split.last) rescue nil).to_s
