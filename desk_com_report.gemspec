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

  
  s.add_dependency("trollop")
  s.add_dependency("chronic")
  s.add_dependency("rest-client")
  s.add_dependency("json_pure")

  if RUBY_VERSION.to_f < 1.9
    s.add_dependency("fastercsv")
  end


  s.bindir       = "bin"
  s.files        = Dir.glob("**/*")
  s.executables  = Dir.glob("bin/*").collect{|f| File.basename(f)}
end
