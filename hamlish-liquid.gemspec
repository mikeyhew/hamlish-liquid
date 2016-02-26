
Gem::Specification.new do |s|
    s.name 		= 'hamlish-liquid'
    s.version   = '0.0.1.alpha'
    s.platform  = Gem::Platform::RUBY
    s.license   = 'MIT'
    s.authors   = 'Michael Hewson'
    s.summary   = 'HAML-like syntax for Liquid (github.com/shopify/liquid)'
    s.require_path = 'lib'
    s.executables = ['hamlish-liquid']
    s.bindir = 'bin'

    s.add_runtime_dependency 'haml'

    s.add_development_dependency 'rake'
    s.add_development_dependency 'minitest'
end