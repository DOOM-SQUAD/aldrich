# Helper Functions
# ----------------
def base_path
  File.dirname(File.expand_path(__FILE__))
end

def boot_file_name
  @name ||= File.join(base_path, 'lib', 'aldrich')
end

# Dependencies
# ------------
require 'rubygems'
require 'bundler'
require 'pry'
require boot_file_name

Bundler.require(:default, :development)

# Tasks
# --------------
task :default => [:spec]

task :spec do
  sh "rspec spec/"
end

desc "Boot an application console in a pry REPL"
task :aldrichshell do
  binding.pry Aldrich
end
