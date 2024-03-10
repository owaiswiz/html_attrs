# frozen_string_literal: true

require_relative 'lib/html_attrs'

Gem::Specification.new do |spec|
  spec.name = 'html_attrs'
  spec.version = HtmlAttrs::VERSION
  spec.authors = ['Owais']
  spec.email = ['owaiswiz@gmail.com']

  spec.summary = 'A gem that provides a way to smartly merge HTML attributes'
  spec.description = 'A gem that provides a way to smartly merge HTML attributes'
  spec.homepage = 'https://github.com/owaiswiz/html_attrs'
  spec.license = 'MIT'
  spec.required_ruby_version = '>= 2.6.0'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = spec.homepage
  spec.metadata['changelog_uri'] = spec.homepage + '/releases'

  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) || f.start_with?(*%w[bin/ test/ spec/ features/ .git .circleci appveyor])
    end
  end
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'actionview', '>= 6.0'
  spec.add_dependency 'activesupport', '>= 6.0'
end
