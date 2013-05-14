# -*- encoding: utf-8 -*-
 
Gem::Specification.new do |s|
  s.name        = "desk_com_report"
  s.version     = "0.0.1"
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Dan Langevin"]
  s.email       = ["dan.langevin@lifebooker.com"]
  s.homepage    = "http://github.com/LifebookerInc/desk_com_report"
  s.summary     = "Script to run reports from Desk.com"
  s.description = "Generates a CSV for Concierge"

  
  s.add_runtime_dependency("trollop")
  s.add_runtime_dependency("chronic")
  s.add_runtime_dependency("rest-client")
  
  s.required_rubygems_version = ">= 1.3.6"
  s.bindir       = "bin"
  s.files        = Dir.glob("**/*")
  s.executables  = Dir.glob("bin/*").collect{|f| File.basename(f)}
end
