Gem::Specification.new do |s|
  s.name        = "glimte"
  s.version     = "0.0.0"
  s.summary     = "Glimte is a MVVM framework based on Glimmer for building desktop apps"
  # s.description = "..."
  s.author      = "Mikhail Fedotov"
  s.email       = "cat@programmicat.bg"
  s.files       = Dir['lib/glimte.rb']
  # s.files       = Dir['lib/**/*.rb']
  # s.homepage    = "..."
  s.license     = "MIT"

  s.required_ruby_version = '>= 2.7.0'

  s.add_runtime_dependency "glimmer-dsl-tk", "~> 0.0.62"
  # TODO: why it isn't requested by Glimmer itself? am I missing something?
  s.add_runtime_dependency "concurrent-ruby", "~> 1.0", ">= 1.0.2"
  s.add_runtime_dependency "zeitwerk", "~> 2.6"
  # TODO: well, should we get rid of ActiveSupport?
  s.add_runtime_dependency "activesupport", "~> 7.0"
  s.add_runtime_dependency "memoized", "~> 1.1"
  s.add_runtime_dependency "listen", "~> 3.7"
  s.add_runtime_dependency "tty-option", "~> 0.2.0"
  s.add_runtime_dependency "pastel", "~> 0.8.0"

  s.executables << "glimte"
end