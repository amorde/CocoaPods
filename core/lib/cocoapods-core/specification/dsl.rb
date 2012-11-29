require 'cocoapods-core/specification/dsl/attribute'

module Pod
  class Specification

    # The of the methods defined in this file and the order of the methods is
    # relevant for the documentation generated by the `doc:generate` rake task.

    # A specification describes a Pod. It includes details about where the
    # source should be fetched from, what files to use, the build settings to
    # apply, and other general metadata such as its name, version, and
    # description.
    #
    # ------------------
    #
    # A stub specification file can be generated by the [pod spec
    # create](commands.html#tab_spec-create) command.
    #
    # ------------------
    #
    # Specification can be very simple:
    #
    #     Pod::Spec.new do |spec|
    #       spec.name     = 'AFNetworking'
    #       spec.version  = '1.0.1'
    #       spec.license  = 'MIT'
    #       spec.summary  = 'A delightful iOS and OS X networking framework.'
    #       spec.homepage = 'https://github.com/AFNetworking/AFNetworking'
    #       spec.authors  = {'Mattt Thompson' => 'm@mattt.me', 'Scott Raymond' => 'sco@gowalla.com'}
    #       spec.source   = { :git => 'https://github.com/AFNetworking/AFNetworking.git', :tag => '1.0.1' }
    #     end
    #
    # Yet it offers attributes that provide great flexibility.
    #
    module DSL

      extend   Pod::Specification::DSL::Attributes
      include  Pod::Specification::DSL::AttributeSupport

      # @!group DSL: Root specification
      #
      #   A ‘root’ specification is a specification that holds other
      #   ‘sub-specifications’.
      #
      #   These attributes can only be written to on the ‘root’ specification,
      #   **not** on the ‘sub-specifications’.
      #
      #   ------------------
      #
      #   The attributes listed in this group are the only one which are
      #   required by a podspec. The attributes of the other groups are offered
      #   to refine the podspec and follow a convention over configuration
      #   approach.

      # @!method name=(name)
      #
      #   The name of the Pod.
      #
      #   @example
      #
      #     spec.name = 'AFNetworking'
      #
      #   @param [String] name
      #
      attribute :name, {
        :required       => true,
        :root_only      => true,
        :multi_platform => false,
      }

      # @return [String] The name of the specification _including_ the names of
      #   the parents, in case of ‘sub-specifications’.
      #
      def name
        @parent ? "#{@parent.name}/#{@name}" : @name
      end

      #------------------#

      # @!method version
      #
      #   The version of the Pod. CocoaPods follows
      #   [semantic versioning](http://semver.org).
      #
      #   @example
      #
      #     spec.version = '0.0.1'
      #
      #   @param  [String] version
      #           the version of the Pod.
      #
      attribute :version, {
        :required       => true,
        :root_only      => true,
        :multi_platform => false,
      }

      # @return [Version] The version of the Pod.
      #
      def _prepare_version(version)
        Version.new(version)
      end

      #------------------#

      # @!method authors=(authors)
      #
      #   The name and email address of each of the library’s the authors.
      #
      #   @example
      #
      #     spec.author = 'Darth Vader'
      #
      #   @example
      #
      #     spec.authors = 'Darth Vader', 'Wookiee'
      #
      #   @example
      #
      #     spec.authors = { 'Darth Vader' => 'darthvader@darkside.com',
      #                      'Wookiee'     => 'wookiee@aggrrttaaggrrt.com' }
      #
      #   @param  [String, Hash{String=>String}] authors
      #           the list of the authors of the library and their emails.
      #
      attribute :authors, {
        :types          => [ String, Array, Hash ],
        :required       => true,
        :root_only      => true,
        :singularize    => true,
        :multi_platform => false,
      }

      # @return [Hash] a hash containing the authors as the keys and their
      #         email address as the values.
      #
      def _prepare_authors(authors)
        if authors.is_a?(Hash)
          authors
        elsif authors.is_a?(Array)
          result = {}
          authors.each do |name_or_hash|
             if name_or_hash.is_a?(String)
               result[name_or_hash] = nil
             else
               result.merge!(name_or_hash)
             end
           end
          result
        elsif authors.is_a?(String)
          { authors => nil }
        end
      end

      #------------------#

      # The keys accepted by the license attribute.
      #
      LICENSE_KEYS = [ :type, :file, :text ].freeze

      # @!method license=(license)
      #
      #   The license of the Pod.
      #
      #   ------------------
      #
      #   Unless the source contains a file named `LICENSE.*` or `LICENCE.*`,
      #   the path of the license file **or** the integral text of the grant
      #   must be specified.
      #
      #   @example
      #
      #     spec.license = 'MIT'
      #
      #   @example
      #
      #     spec.license = { :type => 'MIT', :file => 'MIT-LICENSE.txt' }
      #
      #   @example
      #
      #     spec.license = { :type => 'MIT', :text => <<-LICENSE
      #                        Copyright 2012
      #                        Permission is granted to...
      #                      LICENSE
      #                    }
      #
      #   @param  [String, Hash{Symbol=>String}] license
      #           The type of the lincense and the text of the grant that
      #           allows to use the library (or the relative path to the file
      #           that contains it).
      #
      attribute :license, {
        :container      => Hash,
        :keys           => LICENSE_KEYS,
        :required       => true,
        :multi_platform => false,
        :root_only      => true,
      }

      # @return [Hash] A hash containing the license information of the Pod.
      #
      def _prepare_license(value)
        license = value.is_a?(String) ? { :type => value } : value
        if license[:text]
          license[:text] = license[:text].strip_heredoc.gsub(/\n$/, '')
        end
        license
      end

      #------------------#

      # @!method homepage=(homepage)
      #
      #   The URL of the homepage of the Pod.
      #
      #   @example
      #
      #     spec.homepage = 'www.example.com'
      #
      #   @param  [String] homepage
      #
      #
      # @!method homepage
      #
      #   @return [String] The URL of the homepage of the Pod.
      #
      attribute :homepage, {
        :required       => true,
        :multi_platform => false,
        :root_only      => true,
      }

      #------------------#

      # The keys accepted by the hash of the source attribute.
      #
      SOURCE_KEYS = {
        :git   => [:tag, :branch, :commit, :submodules],
        :svn   => [:folder, :tag, :revision],
        :hg    => [:revision],
        :http  => nil,
        :local => nil
      }.freeze

      # @!method source=(source)
      #
      #   The location from where the library should be retrieved.
      #
      #   @example
      #
      #     spec.source = { :git => "git://github.com/AFNetworking/AFNetworking.git" }
      #
      #   @example
      #
      #     spec.source = { :git => "git://github.com/AFNetworking/AFNetworking.git",
      #                     :tag => 'v0.0.1' }
      #
      #   @example
      #
      #     spec.source = { :git => "git://github.com/AFNetworking/AFNetworking.git",
      #                     :tag => "v#{spec.version}" }
      #
      #   @param  [Hash{Symbol=>String}] source
      #
      #
      # @!method source
      #
      #   @return [Hash{Symbol=>String}] The location from where the library
      #     should be retrieved.
      #
      attribute :source, {
        :container      => Hash,
        :keys           => SOURCE_KEYS,
        :required       => true,
        :root_only      => true,
        :multi_platform => false,
      }

      #------------------#

      # @!method summary=(summary)
      #
      #   A short description of the Pod.
      #
      #   ------------------
      #
      #   It should have a maximum of 140 characters.
      #
      #   @example
      #
      #     spec.summary = 'A library that computes the meaning of life.'
      #
      #   @param  [String] summary
      #
      #
      # @!method summary
      #
      #   @return [String] A short description of the Pod.
      #
      attribute :summary, {
        :required       => true,
        :multi_platform => false,
        :root_only      => true,
      }

      #------------------#

      # @!method description=(description)
      #
      #   A longer description of the Pod.
      #
      #   @example
      #
      #     spec.description = <<-DESC
      #                          A library that computes the meaning of life. Features:
      #                          1. Is self aware
      #                          ...
      #                          42. Likes candies.
      #                        DESC
      #
      #   @param  [String] description
      #
      #
      # @!method description
      #
      #   @return [String] A longer description of the Pod.
      #
      attribute :description, {
        :multi_platform => false,
        :root_only      => true,
      }

      def _prepare_description(description)
        description.strip_heredoc
      end

      #------------------#

      # @!method screenshots=(screenshots)
      #
      #   A list of URLs to images showcasing the Pod. Intended for UI oriented
      #   libraries.
      #
      #   @example
      #
      #     spec.screenshot  = "http://dl.dropbox.com/u/378729/MBProgressHUD/1.png"
      #
      #   @example
      #
      #     spec.screenshots = [ "http://dl.dropbox.com/u/378729/MBProgressHUD/1.png",
      #                          "http://dl.dropbox.com/u/378729/MBProgressHUD/2.png" ]
      #
      #   @param  [String] screenshots
      #
      #
      # @!method screenshots
      #
      #   @return [String] An URL for the screenshot of the Pod.
      #
      attribute :screenshots, {
        :multi_platform => false,
        :root_only      => true,
        :singularize    => true,
        :container      => Array,
      }

      #------------------#

      # @!method documentation=(documentation)
      #
      #   Additional options to pass to the
      #   [appledoc](http://gentlebytes.com/appledoc/) tool.
      #
      #   @example
      #
      #     spec.documentation = { :appledoc => ['--no-repeat-first-par',
      #                                          '--no-warn-invalid-crossref'] }
      #
      #   @param  [Hash{Symbol=>Array<String>}] documentation
      #
      #
      # @!method documentation
      #
      #   @return [Hash{Symbol=>Array<String>}]
      #
      attribute :documentation, {
        :container      => Hash,
        :root_only      => true,
        :multi_platform => false,
      }

      #-----------------------------------------------------------------------#

      # @!group DSL: Platform

      # The names of the platforms supported by the specification class.
      #
      PLATFORMS = [:osx, :ios].freeze

      # @!method platform=(name_and_deployment_target)
      #
      #   The platform on which this Pod is supported.
      #
      #   ------------------
      #
      #   Leaving this blank means the Pod is supported on all platforms.
      #
      #   @example
      #
      #     spec.platform = :ios
      #
      #   @example
      #
      #     spec.platform = :osx
      #
      #   @example
      #
      #     spec.platform = :osx, "10.8"
      #
      #   @param  [Array<Symbol, String>] name_and_deployment_target
      #           A tuple where the first value is the name of the platform,
      #           (either `:ios` or `:osx`) and the second is the deployment
      #           target.
      #
      #
      # @!method platform
      #
      #   @return [Platform] The platform of the specification.
      #
      attribute :platform, {
        :types          => [Array, Symbol],
        :multi_platform => false,
      }

      def _prepare_platform(name_and_deployment_target)
        return nil if name_and_deployment_target.nil?
        if name_and_deployment_target.is_a?(Array)
          name = name_and_deployment_target.first
          deployment_target = name_and_deployment_target.last
        else
          name = name_and_deployment_target
          deployment_target = nil
        end
        unless PLATFORMS.include?(name)
          raise StandardError, "Unsupported platform `#{name}`. The available " \
            "names are `#{PLATFORMS.inspect}`"
        end
        Platform.new(name, deployment_target)
      end

      #------------------#

      # @!method deployment_target=(deployment_target)
      #
      #   The deployment targets of the supported platforms.
      #
      #   @example
      #
      #     spec.ios.deployment_target = "6.0"
      #
      #   @example
      #
      #     spec.osx.deployment_target = "10.8"
      #
      #   @param    [String] deployment_target
      #             The deployment target of the platform.
      #
      #   @raise    If there is an attempt to set the deployment target for
      #             more than one platform.
      #
      #
      # @!method deployment_target
      #
      #   @return [Version] The deployment target of each supported platform.
      #
      attribute :deployment_target, {
      }

      def _prepare_deployment_target(deployment_target)
        unless @define_for_platforms.count == 1
          raise StandardError, "The deployment target must be defined per platform like `s.ios.deployment_target = '5.0'`."
        end
        Version.new(deployment_target)
      end

      #-----------------------------------------------------------------------#

      # @!group DSL: Build configuration

      # @!method requires_arc=(flag)
      #
      #   Wether the `-fobjc-arc' flag should be added to the compiler
      #   flags.
      #
      #   @example
      #
      #     spec.requires_arc = true
      #
      #   @param [Bool] flag
      #           whether the source files require ARC.
      #
      attribute :requires_arc, {
        :types   => [TrueClass, FalseClass],
      }

      #------------------#

      # @!method frameworks=(*frameworks)
      #
      #   A list of frameworks that the user’s target (application) needs to
      #   link against.
      #
      #   @example
      #
      #     spec.ios.framework = 'CFNetwork'
      #
      #   @example
      #
      #     spec.frameworks = 'QuartzCore', 'CoreData'
      #
      #   @param  [String, Array<String>] frameworks
      #           A list of framework names.
      #
      #
      # @!method frameworks
      #
      #   @return [Array<String>] A list of frameworks that the user’s target
      #     needs to link against
      #
      attribute :frameworks, {
        :container   => Array,
        :singularize => true
      }

      #------------------#

      # @!method weak_frameworks=(*frameworks)
      #
      #   A list of frameworks that the user’s target (application) needs to
      #   **weakly** link against.
      #
      #   @example
      #
      #     spec.framework = 'Twitter'
      #
      #   @param  [String, Array<String>] weak_frameworks
      #           A list of frameworks names.
      #
      #
      # @!method weak_frameworks
      #
      #   @return [Array<String>] A list of frameworks that the user’s target
      #     needs to **weakly** link against
      #
      attribute :weak_frameworks, {
        :container   => Array,
        :singularize => true
      }

      #------------------#

      # @!method libraries=(*libraries)
      #
      #   A list of libraries that the user’s target (application) needs to
      #   link against.
      #
      #   @example
      #
      #     spec.ios.library = 'xml2'
      #
      #   @example
      #
      #     spec.libraries = 'xml2', 'z'
      #
      #   @param  [String, Array<String>] libraries
      #           A list of library names.
      #
      #
      # @!method libraries
      #
      #   @return [Array<String>] A list of libraries that the user’s target
      #     needs to link against
      #
      attribute :libraries, {
        :container   => Array,
        :singularize => true
      }

      #------------------#

      # @!method libraries=(*libraries)
      #
      #   A list of libraries that the user’s target (application) needs to
      #   link against.
      #
      #   @example
      #
      #     spec.ios.library = 'xml2'
      #
      #   @example
      #
      #     spec.libraries = 'xml2', 'z'
      #
      #   @param  [String, Array<String>] libraries
      #           A list of library names.
      #
      #
      # @!method libraries
      #
      #   @return [Array<String>] A list of libraries that the user’s target
      #     needs to link against
      #
      attribute :compiler_flags, {
        :container   => Array,
        :singularize => true
      }

      #------------------#

      # @!method xcconfig=(value)
      #
      #   Any flag to add to final xcconfig file.
      #
      #   @example
      #
      #     spec.xcconfig = { 'OTHER_LDFLAGS' => '-lObjC' }
      #
      #   @param  [Hash{String => String}] value
      #           A representing an xcconfig.
      #
      #
      # @!method xcconfig
      #
      #   @return [Hash{String => String}] the xcconfig flags for the current
      #           specification.
      #
      attribute :xcconfig, {
        :container => Hash,
      }

      #------------------#

      # @!method prefix_header_contents=(content)
      #
      #   Any content to inject in the prefix header of the pod project.
      #
      #   ------------------
      #
      #   This attribute is not recommended as Pods should not pollute the
      #   prefix header of other libraries or of the user project.
      #
      #   @example
      #
      #     spec.prefix_header_contents = '#import <UIKit/UIKit.h>'
      #
      #   @example
      #
      #     spec.prefix_header_contents = '#import <UIKit/UIKit.h>', '#import <Foundation/Foundation.h>'
      #
      #   @param  [String] content
      #           The contents of the prefix header.
      #
      #
      # @!method prefix_header_contents
      #
      #   @return [String] The contents of the prefix header.
      #
      attribute :prefix_header_contents, {
        :types   => [Array, String],
      }

      def _prepare_prefix_header_contents(value)
        value.is_a?(Array) ? value * "\n" : value
      end

      #------------------#

      # @!method prefix_header_file=(path)
      #
      #   A path to a prefix header file to inject in the prefix header of the
      #   pod project.
      #
      #   ------------------
      #
      #   This attribute is not recommended as Pods should not pollute the
      #   prefix header of other libraries or of the user project.
      #
      #   @example
      #
      #     spec.prefix_header_file = 'iphone/include/prefix.pch'
      #
      #   @param  [String] path
      #           The path to the prefix header file.
      #
      #
      # @!method prefix_header_file
      #
      #   @return [Pathname] The path of the prefix header file.
      #
      attribute :prefix_header_file

      #------------------#

      # @!method header_dir=(dir)
      #
      #   The directory where to store the headers files so they don't break
      #   includes.
      #
      #   @example
      #
      #     spec.header_dir = 'Three20Core'
      #
      #   @param  [String] dir
      #           the headers directory.
      #
      #
      # @!method header_dir
      #
      #   @return [Pathname] the headers directory.
      #
      attribute :header_dir

      #------------------#

      # @!method header_mappings_dir=(dir)
      #
      #   A directory from where to preserve the folder structure for the
      #   headers files.
      #
      #   ------------------
      #
      #   If not provided the headers files are flattened.
      #
      #   @example
      #
      #     spec.header_mappings_dir = 'src/include'
      #
      #   @param  [String] dir
      #           the directory from where to preserve the headers namespacing.
      #
      #
      # @!method header_mappings_dir
      #
      #   @return [Pathname] the directory from where to preserve the headers
      #           namespacing.
      #
      attribute :header_mappings_dir

      #-----------------------------------------------------------------------#

      # @!group DSL: File patterns
      #
      #   These paths should be specified **relative** to the **root** of the
      #   source and may contain the following wildcard patterns:
      #
      #   ------------------
      #
      #   ### Pattern: *
      #
      #   Matches any file. Can be restricted by other values in the glob.
      #
      #   * `*` will match all files
      #   * `c*` will match all files beginning with `c`
      #   * `*c` will match all files ending with `c`
      #   * `*c*` will match all files that have `c` in them (including at the
      #     beginning or end)
      #
      #   Equivalent to `/.*/x` in regexp.
      #
      #   **Note** this will not match Unix-like hidden files (dotfiles). In
      #   order to include those in the match results, you must use something
      #   like `{*,.*}`.
      #
      #   ------------------
      #
      #   ### Pattern: **
      #
      #   Matches directories recursively.
      #
      #   ------------------
      #
      #   ### Pattern: ?
      #
      #   Matches any one character. Equivalent to `/.{1}/` in regexp.
      #
      #   ------------------
      #
      #   ### Pattern: [set]
      #
      #   Matches any one character in set.
      #
      #   Behaves exactly like character sets in Regexp, including set negation
      #   (`[^a-z]`).
      #
      #   ------------------
      #
      #   ### Pattern: {p,q}
      #
      #   Matches either literal `p` or literal `q`.
      #
      #   Matching literals may be more than one character in length. More than
      #   two literals may be specified.
      #
      #   Equivalent to pattern alternation in regexp.
      #
      #   ------------------
      #
      #   ### Pattern: \
      #
      #   Escapes the next meta-character.
      #
      #   ------------------
      #
      #   ### Examples
      #
      #   Consider these to be evaluated in the source root of
      #   [JSONKit](https://github.com/johnezang/JSONKit).
      #
      #       "JSONKit.?"    #=> ["JSONKit.h", "JSONKit.m"]
      #       "*.[a-z][a-z]" #=> ["CHANGELOG.md", "README.md"]
      #       "*.[^m]*"      #=> ["JSONKit.h"]
      #       "*.{h,m}"      #=> ["JSONKit.h", "JSONKit.m"]
      #       "*"            #=> ["CHANGELOG.md", "JSONKit.h", "JSONKit.m", "README.md"]
      #

      # @!method source_files=(source_files)
      #
      #   The source files of the Pod.
      #
      #   @example
      #
      #     spec.source_files = "Classes/**/*.{h,m}"
      #
      #   @example
      #
      #     spec.source_files = "Classes/**/*.{h,m}", "More_Classes/**/*.{h,m}"
      #
      #   @param  [String, Array<String>] source_files
      #
      #
      # @!method source_files
      #
      #   @return [Array<String>, FileList]
      #
      attribute :source_files, {
        :container     => Array,
        :file_patterns => true,
        :default_value => [ 'Classes/**/*.{h,m}' ],
      }

      #------------------#

      # @!method public_header_files=(public_header_files)
      #
      #   A list of file patterns that should be used as public headers.
      #
      #   ------------------
      #
      #   These are the headers that will be exposed to the user’s project and
      #   from which documentation will be generated. If no public headers are
      #   specified then **all** the headers are considered public.
      #
      #   @example
      #
      #     spec.public_header_files = "Headers/Public/*.h"
      #
      #   @param  [String, Array<String>] public_header_files
      #
      #
      # @!method public_header_files
      #
      #   @return [Array<String>, FileList]
      #
      attribute :public_header_files, {
        :container => Array,
        :file_patterns => true,
      }

      #------------------#

      # The possible destinations for the `resources` attribute. Extracted form
      # `Xcodeproj::Constants.COPY_FILES_BUILD_PHASE_DESTINATIONS`.
      #
      RESORUCES_DESTINATIONS = [
        :products_directory,
        :wrapper,
        :resources,
        :executables,
        :java_resources,
        :frameworks,
        :shared_frameworks,
        :shared_support,
        :plug_ins,
      ].freeze

      # @!method resources=(resources)
      #
      #   A list of resources that should be copied into the target bundle.
      #
      #   ------------------
      #
      #   It is possible to specify a destination, if not specified the files
      #   are copied to the `resources` folder of the bundle.
      #
      #   @example
      #
      #     spec.resource = "Resources/HockeySDK.bundle"
      #
      #   @example
      #
      #     spec.resources = "Resources/*.png"
      #
      #   @example
      #
      #     spec.resources = { :frameworks => 'frameworks/CrashReporter.framework' }
      #
      #   @param  [Hash, String, Array<String>] resources
      #
      #
      # @!method resources
      #
      #   @return [Array<String>, FileList] A hash where the key represents the
      #           paths of the resources to copy and the values the paths of
      #           the resources that should be copied.
      #
      attribute :resources, {
        :types         => [String, Array],
        :file_patterns => true,
        :container     => Hash,
        :keys          => RESORUCES_DESTINATIONS,
        :default_value => { :resources => [ 'Resources/**/*' ] },
        :singularize   => true,
      }

      def _prepare_resources(value)
        value = { :resources => value } unless value.is_a?(Hash)
        result = {}
        value.each do |key, patterns|
          patterns = [ patterns ] if patterns.is_a?(String)
          result[key] = patterns
        end
        result
      end

      #------------------#

      # @!method exclude_files=(exclude_files)
      #
      #   A list of file patterns that should be excluded from the other
      #   attributes.
      #
      #   @example
      #
      #     spec.ios.exclude_files = "Classes/osx"
      #
      #   @example
      #
      #     spec.exclude_files = "Classes/**/unused.{h,m}"
      #
      #   @param  [String, Array<String>] exclude_files
      #
      #
      # @!method exclude_files
      #
      #   @return [Array<String>, Rake::FileList]
      #
      attribute :exclude_files, {
        :container   => Array,
        :file_patterns => true,
        :ios_default => [ 'Classes/osx/**/*', 'Resources/osx/**/*' ],
        :osx_default => [ 'Classes/ios/**/*', 'Resources/ios/**/*' ],
      }

      #------------------#

      # @!method preserve_paths=(preserve_paths)
      #
      #   Any file that should **not** be removed after being downloaded.
      #
      #   ------------------
      #
      #   By default, CocoaPods removes all files that are not matched by any
      #   of the other file pattern attributes.
      #
      #   @example
      #
      #     spec.preserve_path = "IMPORTANT.txt"
      #
      #   @example
      #
      #     spec.preserve_paths = "Frameworks/*.framework"
      #
      #   @param  [String, Array<String>] preserve_paths
      #
      #
      # @!method preserve_paths
      #
      #   @return [Array<String>, FileList]
      #
      attribute :preserve_paths, {
        :container     => Array,
        :file_patterns => true,
        :singularize   => true
      }

      #-----------------------------------------------------------------------#

      # @!group DSL: Hooks
      #
      #   The specification class provides hooks which are called by CocoaPods
      #   when a Pod is installed.

      # This is a convenience method which gets called after all pods have been
      # downloaded but before they have been installed, and the Xcode project
      # and related files have been generated.
      #
      # It receives the `Pod::LocalPod` instance generated form the
      # specification and the `Pod::Podfile::TargetDefinition` instance for the
      # current target.
      #
      # Override this to, for instance, to run any build script.
      #
      # @example
      #
      #   Pod::Spec.new do |spec|
      #     spec.pre_install do |pod, target_definition|
      #       Dir.chdir(pod.root){ `sh make.sh` }
      #     end
      #   end
      #
      def pre_install(&block)
        @pre_install_callback = block
      end

      # This is a convenience method which gets called after all pods have been
      # downloaded, installed, and the Xcode project and related files have
      # been generated.
      #
      # It receives the `Pod::Installer::TargetInstaller` instance for the
      # current target.
      #
      # Override this to, for instance, add to the prefix header.
      #
      # @example
      #
      #   Pod::Spec.new do |spec|
      #     spec.post_install do |target_installer|
      #       prefix_header = config.project_pods_root + target_installer.prefix_header_filename
      #       prefix_header.open('a') do |file|
      #         file.puts('#ifdef __OBJC__\n#import "SSToolkitDefines.h"\n#endif')
      #       end
      #     end
      #   end
      #
      def post_install(&block)
        @post_install_callback = block
      end

      #-----------------------------------------------------------------------#

      # @!group DSL: Dependencies

      # Specification for a module of the Pod. A specification automatically
      # inherits as a dependency all it children subspecs.
      #
      # Subspec also inherits values from their parents so common values for
      # attributes can be specified in the ancestors.
      #
      # @example
      #
      #   subspec "core" do |sp|
      #     sp.source_files = "Classes/Core"
      #   end
      #
      #   subspec "optional" do |sp|
      #     sp.source_files = "Classes/BloatedClassesThatNobodyUses"
      #   end
      #
      # @example
      #
      #   subspec "Subspec" do |sp|
      #     sp.subspec "resources" do |ssp|
      #     end
      #   end
      #
      def subspec(name, &block)
        subspec = Specification.new(self, name, &block)
        @subspecs << subspec
        subspec
      end

      #------------------#

      # @!method default_subspec=(subspec_name)
      #
      #   The name of the subspec that should be used as preferred dependency.
      #   If not specified a specifications requires all its subspecs as
      #   dependencies.
      #
      #   ------------------
      #
      #   A Pod should make available the full library by default. Users can
      #   fine tune their dependencies once their requirements are known.
      #   Therefore, This attribute is rarely needed and is intended to be used
      #   in cases where there are subspecs incompatible with each other. In
      #   can be also used to exclude modules that interface other libraries
      #   and would trigger those dependencies.
      #
      #   @example
      #     spec.default_subspec = 'Pod/Core'
      #
      #   @param  [String] subspec_name
      #
      # @!method default_subspec
      #
      #   @return [String] the name of the subspec that should be inherited as
      #           dependency.
      #
      attribute :default_subspec, {
        :inherited => false,
      }

      #------------------#

      attribute :dependency, {
        :defined_as => 'dependency',
      }

      # Any dependency on other Pods.
      #
      # ------------------
      #
      # Dependencies can specify versions requirements. The use of the spermy
      # indicator `~>` is recommended because it provides a good compromise
      # between control on the version without being too restrictive.
      #
      # Pods with too restrictive dependencies, limit their compatibility with
      # other Pods.
      #
      # @example
      #   spec.dependency = 'AFNetworking', '~> 1.0'
      #   spec.dependency = 'MagicalRecord', '~> 2.0.8'
      #
      # @example
      #   spec.ios.dependency = 'MBProgressHUD', '~> 0.5'
      #
      def dependency(*name_and_version_requirements)
        name, *version_requirements = name_and_version_requirements.flatten
        raise StandardError, "A specification can't require self as a subspec" if name == self.name
        raise StandardError, "A subspec can't require one of its parents specifications" if @parent && @parent.name.include?(name)
        dep = Dependency.new(name, *version_requirements)
        @define_for_platforms.each do |platform|
          @dependencies[platform] << dep
        end
        dep
      end

      #-----------------------------------------------------------------------#

      # @!group DSL: Multi-Platform support
      #
      #   A specification can store values which are specific to only one
      #   platform.
      #
      #   ------------------
      #
      #   For example one might want to store resources which are specific to
      #   only iOS projects.
      #
      #       spec.resources = "Resources/**/*.png"
      #       spec.ios.resources = "Resources_ios/**/*.png"

      # Provides support for specifying iOS attributes.
      #
      # @example
      #   spec.ios.source_files = "Classes/ios/**/*.{h,m}"
      #
      # @return [PlatformProxy] the proxy that will set the attributes.
      #
      def ios
        PlatformProxy.new(self, :ios)
      end

      # Provides support for specifying OS X attributes.
      #
      # @example
      #   spec.osx.source_files = "Classes/osx/**/*.{h,m}"
      #
      # @return [PlatformProxy] the proxy that will set the attributes.
      #
      def osx
        PlatformProxy.new(self, :osx)
      end
    end
  end
end
