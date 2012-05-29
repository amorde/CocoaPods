require 'fileutils'

module Pod
  class Command
    class Repo < Command
      def self.banner
%{Managing spec-repos:

    $ pod repo add NAME URL [BRANCH]

      Clones `URL' in the local spec-repos directory at `~/.cocoapods'. The
      remote can later be referred to by `NAME'.

    $ pod repo update NAME

      Updates the local clone of the spec-repo `NAME'. If `NAME' is omitted
      this will update all spec-repos in `~/.cocoapods'.}
      end

      extend Executable
      executable :git

      def initialize(argv)
        case @action = argv.arguments[0]
        when 'add'
          unless (@name = argv.arguments[1]) && (@url = argv.arguments[2])
            raise Informative, "#{@action == 'add' ? 'Adding' : 'Updating the remote of'} a repo needs a `name' and a `url'."
          end
          @branch = argv.arguments[3]
        when 'update'
          @name = argv.arguments[1]
        else
          super
        end
      end

      def dir
        config.repos_dir + @name
      end

      def run
        send @action.gsub('-', '_')
      end

      def add
        print_subtitle "Cloning spec repo `#{@name}' from `#{@url}'#{" (branch `#{@branch}')" if @branch}"
        config.repos_dir.mkpath
        Dir.chdir(config.repos_dir) { git("clone '#{@url}' #{@name}") }
        Dir.chdir(dir) { git("checkout #{@branch}") } if @branch
        check_versions(dir)
      end

      def update
        dirs = @name ? [dir] : config.repos_dir.children.select {|c| c.directory?}
        dirs.each do |dir|
          print_subtitle "Updating spec repo `#{dir.basename}'"
          Dir.chdir(dir) do
            `git rev-parse  >/dev/null 2>&1`
            if $?.exitstatus.zero?
              git("pull")
            else
              puts("   Not a git repository") if config.verbose?
            end
          end
          check_versions(dir)
        end
      end

      def check_versions(dir)
        versions = versions(dir)
        unless is_compatilbe(versions)
          min, max = versions['min'], versions['max']
          version_msg = ( min == max ) ? min : "#{min} - #{max}"
          raise Informative,
          "\n[!] The `#{dir.basename.to_s}' repo requires CocoaPods #{version_msg}\n".red +
          "Update Cocoapods, or checkout the appropriate tag in the repo.\n\n"
        end
        puts "\nCocoapods #{versions['last']} is available.\n".green if has_update(versions)
      end

      def self.compatible?(name)
        dir = Config.instance.repos_dir + name
        versions = versions(dir)
        is_compatilbe(versions)
      end

      private

      def versions(dir)
        self.class.versions(dir)
      end

      def self.versions(dir)
        require 'yaml'
        yaml_file  = dir + 'CocoaPods-version.yml'
        yaml_file.exist? ? YAML.load_file(yaml_file) : {}
      end

      def is_compatilbe(versions)
        self.class.is_compatilbe(versions)
      end

      def self.is_compatilbe(versions)
        min, max = versions['min'], versions['max']
        supports_min = !min || bin_version >= Gem::Version.new(min)
        supports_max = !max || bin_version <= Gem::Version.new(max)
        supports_min && supports_max
      end

      def has_update(versions)
        self.class.has_update(versions)
      end

      def self.has_update(versions)
        last = versions['last']
        last && Gem::Version.new(last) > bin_version
      end

      def self.bin_version
        Gem::Version.new(VERSION)
      end

    end
  end
end

