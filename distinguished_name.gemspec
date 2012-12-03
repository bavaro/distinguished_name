# -*- encoding: utf-8 -*-

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'distinguished_name/version'

Gem::Specification.new do |gem|
  gem.name          = "distinguished_name"
  gem.version       = DistinguishedName::VERSION
  gem.authors       = ["Team Bavaro"]
  gem.email         = [""]
  gem.summary       = %q{Methods for interacting with distinguished name strings}
  gem.description   = %q{This is a gem for interacting with the string representation of distinguished names, per the RFC-1779 (http://www.ietf.org/rfc/rfc1779.txt)}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
end
