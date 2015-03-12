require "./lib/html_truncator/version.rb"

Gem::Specification.new do |s|
  s.name             = "html_truncator"
  s.version          = HTML_Truncator::VERSION
  s.date             = Time.now.utc.strftime("%Y-%m-%d")
  s.homepage         = "http://github.com/nono/HTML-Truncator"
  s.authors          = "Bruno Michel"
  s.email            = "bmichel@menfin.info"
  s.description      = "Wants to truncate an HTML string properly? This gem is for you."
  s.summary          = "Wants to truncate an HTML string properly? This gem is for you."
  s.extra_rdoc_files = %w(README.md)
  s.files            = Dir["MIT-LICENSE", "README.md", "Gemfile", "lib/**/*.rb", "init.rb"]
  s.require_paths    = ["lib"]
  s.add_dependency "nokogiri", "~>1.5"
  s.add_development_dependency "rspec", "~>3.0"
end
