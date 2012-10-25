require 'rubygems'

# Better to fail early and clear then during installation of pods.
#
# RubyGems 1.3.6 (which ships with OS X >= 10.7) up to 1.4.0 have a couple of
# bugs related to comparing prerelease versions.
#
# E.g. https://github.com/CocoaPods/CocoaPods/issues/398
unless Gem::Version::Requirement.new('>= 1.4.0').satisfied_by?(Gem::Version.new(Gem::VERSION))
  STDERR.puts "\e[1;31m" + "Your RubyGems version (1.8.24) is too old, please update with: `gem update --system`" + "\e[0m"
  exit 1
end

module Pod

  class StandardError < ::StandardError; end

  def self.raise(message)
   Kernel.raise StandardError, message
  end

  require 'version'
  require 'pathname'

  require 'cocoapods-core/dependency'
  require 'cocoapods-core/platform'
  require 'cocoapods-core/source'
  require 'cocoapods-core/specification'
  require 'cocoapods-core/version'
  require 'cocoapods-core/podfile'
  require 'cocoapods-core/lockfile'
end

if ENV['COCOA_PODS_ENV'] == 'development'
  require 'awesome_print'
end
