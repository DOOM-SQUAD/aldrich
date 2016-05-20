require_relative '../lib/aldrich.rb'

Bundler.require(:default, :development, :test)

require 'pry'

SPEC_ROOT = File.expand_path(File.dirname(__FILE__))
