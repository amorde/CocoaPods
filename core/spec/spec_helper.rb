require 'rubygems'
require 'mac_bacon'

require 'pathname'
ROOT = Pathname.new(File.expand_path('../../', __FILE__))

$:.unshift((ROOT + 'lib').to_s)
require 'cocoa_pods'

$:.unshift((ROOT + 'spec').to_s)
require 'spec_helper/fixture'
require 'spec_helper/git'
require 'spec_helper/log'
require 'spec_helper/temporary_directory'

#TMP_DIR = SpecHelper::TemporaryDirectory.temporary_directory
#TMP_COCOA_PODS_DIR = File.join(TMP_DIR, 'cocoa-pods')

context_class = defined?(BaconContext) ? BaconContext : Bacon::Context
context_class.class_eval do
  include Pod::Config::Mixin

  include SpecHelper::Fixture

  def argv(*argv)
    Pod::Command::ARGV.new(argv)
  end
end

config = Pod::Config.instance
config.silent = true
config.repos_dir = SpecHelper.tmp_repos_path
