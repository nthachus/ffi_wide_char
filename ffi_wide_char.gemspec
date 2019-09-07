# frozen_string_literal: true

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ffi_wide_char/version'

Gem::Specification.new do |spec|
  spec.name          = 'ffi_wide_char'
  spec.version       = FfiWideChar::VERSION
  spec.authors       = ['Thach Nguyen']
  spec.email         = ['nthachus@gmail.com']

  spec.summary       = 'Provides methods to convert from/to FFI wide-string.'
  spec.description   = 'Convert from/to C native `wchar_t` string to used for FFI binding libraries.'
  spec.homepage      = 'https://github.com/nthachus/ffi_wide_char'
  spec.license       = 'MIT'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = spec.homepage
  spec.metadata['changelog_uri'] = spec.homepage

  # Specify which files should be added to the gem when it is released.
  spec.files = Dir.chdir(File.expand_path('..', __FILE__)) do
    ['LICENSE.txt'] + Dir.glob('lib/**/*').reject { |f| File.directory? f }
  end
  spec.require_paths = ['lib']
  spec.required_ruby_version = '>= 2.3'

  spec.add_dependency 'ffi', '~> 1.0'

  spec.add_development_dependency 'bundler', '>= 1.7'
  spec.add_development_dependency 'minitest', '>= 5.9'
  spec.add_development_dependency 'rake', '>= 10.4'
  spec.add_development_dependency 'rubocop', '>= 0.64'
end
