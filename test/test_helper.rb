$:.unshift(File.join(File.dirname(__FILE__), %w[.. lib]))
RAILS_ENV='test' if !defined? RAILS_ENV
RAILS_ROOT=File.expand_path(File.join(File.dirname(__FILE__), '..')) if !defined?(RAILS_ROOT)

require 'rubygems'
require 'rails/version'
require 'active_support'
require 'active_record'
require 'action_controller'

require 'log4r'
