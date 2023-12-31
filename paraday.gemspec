# frozen_string_literal: true

require_relative 'lib/paraday/version'

Gem::Specification.new do |spec|
  spec.name    = 'paraday'
  spec.version = Paraday::VERSION

  spec.summary = 'HTTP/REST API client library.'

  spec.authors  = ['@technoweenie', '@iMacTia', '@olleolleolle']
  spec.email    = 'technoweenie@gmail.com'
  spec.homepage = 'https://lostisland.github.io/faraday'
  spec.licenses = ['MIT']

  spec.required_ruby_version = '>= 2.6'

  spec.add_dependency 'base64'
  # paraday-net_http is the "default adapter", but being a Paraday dependency it can't
  # control which version of paraday it will be pulled from.
  # To avoid releasing a major version every time there's a new Paraday API, we should
  # always fix its required version to the next MINOR version.
  # This way, we can release minor versions of the adapter with "breaking" changes for older versions of Paraday
  # and then bump the version requirement on the next compatible version of paraday.
  spec.add_dependency 'multipart-post', '~> 2.0'
  spec.add_dependency 'ruby2_keywords', '>= 0.0.2'

  # Includes `examples` and `spec` to allow external adapter gems to run Paraday unit and integration tests
  spec.files = Dir['CHANGELOG.md', '{examples,lib,spec}/**/*', 'LICENSE.md', 'Rakefile', 'README.md']
  spec.require_paths = %w[lib spec/external_adapters]
  spec.metadata = {
    'homepage_uri' => 'https://lostisland.github.io/faraday',
    'changelog_uri' =>
      "https://github.com/lostisland/faraday/releases/tag/v#{spec.version}",
    'source_code_uri' => 'https://github.com/lostisland/faraday',
    'bug_tracker_uri' => 'https://github.com/lostisland/faraday/issues'
  }
end
