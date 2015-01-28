
Gem::Specification.new do |s|
  # Project attributes
  s.name        = "iron-console"
  s.summary     = "Console applet development framework"
  s.description = "A small yet powerful command-line driven applet framework for working with Ruby on Linux."

  # Post-install message
  s.post_install_message = "Console code installed - run \"create-script help usage\" to get started"

  # Additional dependencies
  s.add_dependency "iron-extensions", "~> 1.2"
  s.add_dependency "iron-dsl", "~> 1.0"

  # Include all gem files that should be packaged
  s.files = Dir[
    "lib/**/*", 
    "bin/*", 
    "spec/**/*", 
    "LICENSE", 
    "*.txt",
    "*.rdoc",
    ".rspec"
  ]
  # Prune out files we don't want to include
  s.files.reject! do |p| 
    ['.tmproj'].detect {|test| p.include?(test)}
  end
  
  # Meta-info
  s.version     = File.read('Version.txt').strip
  s.authors     = ["Rob Morris"]
  s.email       = ["rob@irongaze.com"]
  s.homepage    = "http://irongaze.com"
  
  # Boilerplate
  s.platform    = Gem::Platform::RUBY
  s.require_path = 'lib'
  s.executables = Dir["bin/*"].collect {|p| File.basename(p)}
  s.add_development_dependency "rspec", "~> 2.6"
  s.required_ruby_version = '>= 1.9.2'
  s.license     = 'MIT'
end