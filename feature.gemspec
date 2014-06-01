require 'rubygems/package_task'

Gem::Specification.new do |s|
  s.name = "feature"
  s.version = "1.0.0"

  s.authors = ["Markus Gerdes", "Hugo Corbucci"]
  s.email = %q{github@mgsnova.de}

  s.homepage = %q{http://github.com/mgsnova/feature}
  s.require_paths = ["lib"]
  s.summary = "Feature Toggle library for ruby"
  s.files = FileList["{lib,spec}/**/*"].exclude("rdoc").to_a + ["Rakefile", "Gemfile", "README.md", "CHANGELOG.md"]
end
