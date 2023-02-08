Gem::Specification.new do |s|
  s.name        = "glimte"
  s.version     = "0.0.1"
  s.summary     = "Glimte is a MVVM framework based on Glimmer for building desktop apps"
  # s.description = "..."
  s.author      = "Mikhail Fedotov"
  s.email       = "cat@programmicat.bg"
  s.files       = Dir['lib/glimte.rb']
  # s.homepage    = "..."
  s.license     = "MIT"

  s.required_ruby_version = '>= 2.7.0'

  s.add_runtime_dependency "concurrent-ruby", "~> 1.1"
  s.add_runtime_dependency "cri", "~> 2.15"
  s.add_runtime_dependency "dry-initializer", "~> 3.1"
  s.add_runtime_dependency "facets", "~> 3.1"
  s.add_runtime_dependency "glimmer-dsl-tk", "~> 0.0.62"
  s.add_runtime_dependency "listen", "~> 3.8"
  s.add_runtime_dependency "memoized", "~> 1.1"
  s.add_runtime_dependency "omnes", "~> 0.2.2"
  s.add_runtime_dependency "pastel", "~> 0.8.0"
  s.add_runtime_dependency "zeitwerk", "~> 2.6"

  s.executables << "glimte"
end
