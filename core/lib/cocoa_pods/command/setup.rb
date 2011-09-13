require 'cocoa_pods/command/repo'

module Pod
  class Command
    class Setup < Command
      def self.banner
%{### Setup

    $ pod help setup

      pod setup
        Creates a directory at `~/.cocoa-pods' which will hold your spec-repos.
        This is where it will create a clone of the public `master' spec-repo.}
      end

      def master_repo_url
        'git://github.com/alloy/cocoa-pod-specs.git'
      end

      def add_master_repo_command
        @command ||= Repo.new('add', 'master', master_repo_url)
      end

      def run
        add_master_repo_command.run
      end
    end
  end
end
