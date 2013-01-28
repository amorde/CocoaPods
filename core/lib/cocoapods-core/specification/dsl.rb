require 'cocoapods-core/specification/dsl/attribute_support'
require 'cocoapods-core/specification/dsl/attribute'
require 'cocoapods-core/specification/dsl/platform_proxy'
require 'cocoapods-core/specification/dsl/deprecations'

module Pod
  class Specification

    #- NOTE ------------------------------------------------------------------#
    # The of the methods defined in this file and the order of the methods is
    # relevant for the documentation generated on the
    # CocoaPods/cocoapods.github.com repository.
    #-------------------------------------------------------------------------#

    # A specification describes a version of Pod library. It includes details
    # about where the source should be fetched from, what files to use, the
    # build settings to apply, and other general metadata such as its name,
    # version, and description.
    #
    # ---
    #
    # A stub specification file can be generated by the [pod spec
    # create](commands.html#tab_spec-create) command.
    #
    # ---
    #
    # The specification DSL provides great flexibility and dynamism. Moreover,
    # the DSL adopts the
    # [convention over configuration](http://en.wikipedia.org/wiki/Convention_over_configuration)
    # and thus it can be very simple:
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
    module DSL

      extend Pod::Specification::DSL::AttributeSupport

      #-----------------------------------------------------------------------#

      # @!group Root specification
      #
      #   A ‘root’ specification stores the information about the specific
      #   version of a library.
      #
      #   The attributes in this group can only be written to on the ‘root’
      #   specification, **not** on the ‘sub-specifications’.
      #
      #   ---
      #
      #   The attributes listed in this group are the only one which are
      #   required by a podspec.
      #
      #   The attributes of the other groups are offered to refine the podspec
      #   and follow a convention over configuration approach.  A root
      #   specification can describe these attributes either directly of
      #   through ‘[sub-specifications](#subspec)’.

      #-----------------------------------------------------------------------#

      # @!method name=(name)
      #
      #   The name of the Pod.
      #
      #   @example
      #
      #     spec.name = 'AFNetworking'
      #
      #   @param  [String] name
      #           the name of the pod.
      #
      root_attribute :name, {
        :required => true,
      }

      #------------------#

      # @!method version=(version)
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
      root_attribute :version, {
        :required => true,
      }

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
      root_attribute :authors, {
        :types       => [ String, Array, Hash ],
        :required    => true,
        :singularize => true,
      }

      #------------------#

      # The keys accepted by the license attribute.
      #
      LICENSE_KEYS = [ :type, :file, :text ].freeze

      # @!method license=(license)
      #
      #   The license of the Pod.
      #
      #   ---
      #
      #   Unless the source contains a file named `LICENSE.*` or `LICENCE.*`,
      #   the path of the license file **or** the integral text of the notice
      #   commonly used for the license type must be specified.
      #
      #   This information is used by CocoaPods to generate acknowledgement
      #   files (markdown and plist) which can be used in the acknowledgements
      #   section of the final application.
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
      #           The type of the license and the text of the grant that
      #           allows to use the library (or the relative path to the file
      #           that contains it).
      #
      root_attribute :license, {
        :container => Hash,
        :keys      => LICENSE_KEYS,
        :required  => true,
      }

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
      #           the URL of the homepage of the Pod.
      #
      root_attribute :homepage, {
        :required => true,
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
      #   @example Specifying a Git source with a tag.
      #
      #     spec.source = { :git => "git://github.com/AFNetworking/AFNetworking.git",
      #                     :tag => 'v0.0.1' }
      #
      #   @example Using the version of the Pod to identify the Git tag.
      #
      #     spec.source = { :git => "git://github.com/AFNetworking/AFNetworking.git",
      #                     :tag => "v#{spec.version}" }
      #
      #   @param  [Hash{Symbol=>String}] source
      #           The location from where the library should be retrieved.
      #
      root_attribute :source, {
        :container => Hash,
        :keys      => SOURCE_KEYS,
        :required  => true,
      }

      #------------------#

      # @!method summary=(summary)
      #
      #   A short (maximum 140 characters) description of the Pod.
      #
      #   ---
      #
      #   The description should be short, yet informative. It represents the
      #   tag line of the Pod and there is no need to specify that a Pod is a
      #   library (they always are).
      #
      #   The summary is expected to be properly capitalized and containing the
      #   correct punctuation.
      #
      #   @example
      #
      #     spec.summary = 'Computes the meaning of life.'
      #
      #   @param  [String] summary
      #           A short description of the Pod.
      #
      root_attribute :summary, {
        :required => true,
      }

      #------------------#

      # @!method description=(description)
      #
      #   A description of the Pod more detailed than the summary.
      #
      #   @example
      #
      #     spec.description = <<-DESC
      #                          Computes the meaning of life.
      #                          Features:
      #                          1. Is self aware
      #                          ...
      #                          42. Likes candies.
      #                        DESC
      #
      #   @param  [String] description
      #           A longer description of the Pod.
      #
      root_attribute :description

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
      #           An URL for the screenshot of the Pod.
      #
      root_attribute :screenshots, {
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
      #           Additional options to pass to the appledoc tool.
      #
      root_attribute :documentation, {
        :container => Hash,
      }

      #-----------------------------------------------------------------------#

      # @!group Platform
      #
      #   A specification should indicate the platforms and the correspondent
      #   deployment targets on which the library is supported.
      #
      #   If not defined in a subspec the attributes of this group inherit the
      #   value of the parent.

      #-----------------------------------------------------------------------#

      # The names of the platforms supported by the specification class.
      #
      PLATFORMS = [:osx, :ios].freeze

      # @todo This currently is not used in the Ruby DSL.
      #
      attribute :platforms, {
        :container      => Hash,
        :keys           => PLATFORMS,
        :multi_platform => false,
        :inherited => true,
      }

      # The platform on which this Pod is supported. Leaving this blank
      # means the Pod is supported on all platforms.
      #
      # @example
      #
      #   spec.platform = :osx, "10.8"
      #
      # @example
      #
      #   spec.platform = :ios
      #
      # @example
      #
      #   spec.platform = :osx
      #
      # @param  [Array<Symbol, String>] name_and_deployment_target
      #         A tuple where the first value is the name of the platform,
      #         (either `:ios` or `:osx`) and the second is the deployment
      #         target.
      #
      def platform=(args)
        name, deployment_target = args
        if name
        attributes_hash["platforms"] = {
          name.to_s => deployment_target
        }
        else
          attributes_hash["platforms"] = {}
        end
      end

      #------------------#

      #  The deployment targets of the supported platforms.
      #
      #  @example
      #
      #    spec.ios.deployment_target = "6.0"
      #
      #  @example
      #
      #    spec.osx.deployment_target = "10.8"
      #
      #  @param    [String] deployment_target
      #            The deployment target of the platform.
      #
      def deployment_target=(*args)
        raise StandardError, "The deployment target can be declared only per platform."
      end

      #-----------------------------------------------------------------------#

      # @!group Build settings
      #
      #   In this group are listed the attributes related to the configuration
      #   of the build environment that should be used to build the library.
      #
      #   If not defined in a subspec the attributes of this group inherit the
      #   value of the parent.

      #-----------------------------------------------------------------------#

      # @todo This currently is not used in the Ruby DSL.
      #
      attribute :dependencies, {
        :container => Hash,
        :inherited => true,
      }

      # Any dependency on other Pods or to a ‘sub-specification’.
      #
      # ---
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
      #
      # @example
      #   spec.dependency = 'RestKit/CoreData', '~> 0.20.0'
      #
      # @example
      #   spec.ios.dependency = 'MBProgressHUD', '~> 0.5'
      #
      def dependency(*args)
        name, *version_requirements = args
        raise StandardError, "A specification can't require self as a subspec" if name == self.name
        raise StandardError, "A subspec can't require one of its parents specifications" if @parent && @parent.name.include?(name)
        attributes_hash["dependencies"] ||= {}
        attributes_hash["dependencies"][name] = version_requirements
      end

      #------------------#

      # @!method requires_arc=(flag)
      #
      #   Wether the library requires ARC to be compiled. If true the
      #   `-fobjc-arc` flag will be added to the compiler flags.
      #
      #   ---
      #
      #   The default value of this attribute is __transitioning__ from `false`
      #   to `true`, and in the meanwhile this attribute is always required.
      #
      #   @example
      #
      #     spec.requires_arc = true
      #
      #   @param [Bool] flag
      #           whether the source files require ARC.
      #
      attribute :requires_arc, {
        :types => [TrueClass, FalseClass],
        :default_value => false,
        :inherited => true,
      }

      #------------------#

      # @!method frameworks=(*frameworks)
      #
      #   A list of frameworks that the user’s target needs to link against.
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
      attribute :frameworks, {
        :container   => Array,
        :singularize => true,
        :inherited => true,
      }

      #------------------#

      # @!method weak_frameworks=(*frameworks)
      #
      #   A list of frameworks that the user’s target needs to **weakly** link
      #   against.
      #
      #   @example
      #
      #     spec.framework = 'Twitter'
      #
      #   @param  [String, Array<String>] weak_frameworks
      #           A list of frameworks names.
      #
      attribute :weak_frameworks, {
        :container   => Array,
        :singularize => true,
        :inherited => true,
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
      attribute :libraries, {
        :container   => Array,
        :singularize => true,
        :inherited => true,
      }

      #------------------#

      # @!method compiler_flags=(flags)
      #
      #   A list of flags which should be passed to the compiler.
      #
      #   @example
      #
      #     spec.compiler_flags = '-DOS_OBJECT_USE_OBJC=0', '-Wno-format'
      #
      #   @param  [String, Array<String>] flags
      #           A list of flags.
      #
      attribute :compiler_flags, {
        :container   => Array,
        :singularize => true,
        :inherited => true,
      }

      #------------------#

      # @!method xcconfig=(value)
      #
      #   Any flag to add to the final xcconfig file.
      #
      #   @example
      #
      #     spec.xcconfig = { 'OTHER_LDFLAGS' => '-lObjC' }
      #
      #   @param  [Hash{String => String}] value
      #           A representing an xcconfig.
      #
      attribute :xcconfig, {
        :container => Hash,
        :inherited => true,
      }

      #------------------#

      # @!method prefix_header_contents=(content)
      #
      #   Any content to inject in the prefix header of the pod project.
      #
      #   ---
      #
      #   This attribute is __not recommended__ as Pods should not pollute the
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
      attribute :prefix_header_contents, {
        :types => [Array, String],
        :inherited => true,
      }

      #------------------#

      # @!method prefix_header_file=(path)
      #
      #   A path to a prefix header file to inject in the prefix header of the
      #   pod project.
      #
      #   ---
      #
      #   This attribute is __not recommended__ as Pods should not pollute the
      #   prefix header of other libraries or of the user project.
      #
      #   @example
      #
      #     spec.prefix_header_file = 'iphone/include/prefix.pch'
      #
      #   @param  [String] path
      #           The path to the prefix header file.
      #
      attribute :prefix_header_file, {
        :inherited => true
      }


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
      attribute :header_dir, {
        :inherited => true
      }

      #------------------#

      # @!method header_mappings_dir=(dir)
      #
      #   A directory from where to preserve the folder structure for the
      #   headers files. If not provided the headers files are flattened.
      #
      #   @example
      #
      #     spec.header_mappings_dir = 'src/include'
      #
      #   @param  [String] dir
      #           the directory from where to preserve the headers namespacing.
      #
      attribute :header_mappings_dir, {
        :inherited => true
      }

      #-----------------------------------------------------------------------#

      # @!group File patterns
      #
      #   These paths should be specified **relative** to the **root** of the
      #   source and may contain the following wildcard patterns:
      #
      #   ---
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
      #   ---
      #
      #   ### Pattern: **
      #
      #   Matches directories recursively.
      #
      #   ---
      #
      #   ### Pattern: ?
      #
      #   Matches any one character. Equivalent to `/.{1}/` in regexp.
      #
      #   ---
      #
      #   ### Pattern: [set]
      #
      #   Matches any one character in set.
      #
      #   Behaves exactly like character sets in Regexp, including set negation
      #   (`[^a-z]`).
      #
      #   ---
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
      #   ---
      #
      #   ### Pattern: \
      #
      #   Escapes the next meta-character.
      #
      #   ---
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

      #-----------------------------------------------------------------------#

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
      #           the source files of the Pod.
      #
      attribute :source_files, {
        :container     => Array,
        :file_patterns => true,
        :default_value => [ 'Classes/**/*.{h,m}'.freeze ].freeze,
      }

      #------------------#

      # @!method public_header_files=(public_header_files)
      #
      #   A list of file patterns that should be used as public headers.
      #
      #   ---
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
      #           the public headers of the Pod.
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
      #   ---
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
      #           the resources of the Pod.
      #
      attribute :resources, {
        :types         => [String, Array],
        :file_patterns => true,
        :container     => Hash,
        :keys          => RESORUCES_DESTINATIONS,
        :default_value => {
          :resources => [ 'Resources/**/*'.freeze ].freeze
        }.freeze,
        :singularize   => true,
      }

      #------------------#

      # @!method exclude_files=(exclude_files)
      #
      #   A list of file patterns that should be excluded from the other
      #   file patterns.
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
      #           the file patterns that the Pod should ignore.
      #
      attribute :exclude_files, {
        :container     => Array,
        :file_patterns => true,
        :ios_default   => [
          'Classes/**/osx/**/*'.freeze,
          'Resources/**/osx/**/*'.freeze
        ].freeze,
        :osx_default   => [
          'Classes/**/ios/**/*'.freeze,
          'Resources/**/ios/**/*'.freeze 
        ].freeze,
      }

      #------------------#

      # @!method preserve_paths=(preserve_paths)
      #
      #   Any file that should **not** be removed after being downloaded.
      #
      #   ---
      #
      #   By default, CocoaPods removes all files that are not matched by any
      #   of the other file pattern.
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
      #           the paths that should be not cleaned.
      #
      attribute :preserve_paths, {
        :container     => Array,
        :file_patterns => true,
        :singularize   => true
      }

      #-----------------------------------------------------------------------#

      # @!group Hooks
      #
      #   The specification class provides hooks which are called by CocoaPods
      #   when a Pod is installed.

      #-----------------------------------------------------------------------#

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

      # @!group Subspecs
      #
      #   A library can specify a dependency on either another library, a
      #   subspec of another library, or a subspec of itself.

      #-----------------------------------------------------------------------#

      # Represents specification for a module of the library.
      #
      # ---
      #
      # Subspecs participate on a dual hierarchy.
      #
      # On one side, a specification automatically inherits as a dependency all
      # it children ‘sub-specifications’ (unless a default subspec is
      # specified).
      #
      # On the other side, a ‘sub-specification’ inherits the value of the
      # attributes of the parents so common values for attributes can be
      # specified in the ancestors.
      #
      # Although it sounds complicated in practice it means that subspecs in
      # general do what you would expect:
      #
      #     pod 'ShareKit', '2.0'
      #
      # Installs ShareKit with all the sharers like `ShareKit/Evernote`,
      # `ShareKit/Facebook`, etc, as they are defined a subspecs.
      #
      #     pod 'ShareKit/Twitter',  '2.0'
      #     pod 'ShareKit/Pinboard', '2.0'
      #
      # Installs ShareKit with only the source files for `ShareKit/Twitter`,
      # `ShareKit/Pinboard`. Note that, in this case, the ‘sub-specifications’
      # to compile need the source files, the dependencies, and the other
      # attributes defined by the root specification. CocoaPods is smart enough
      # to handle any issues arising from duplicate attributes.
      #
      # @example Subspecs with different source files.
      #
      #   subspec "Twitter" do |sp|
      #     sp.source_files = "Classes/Twitter"
      #   end
      #
      #   subspec "Pinboard" do |sp|
      #     sp.source_files = "Classes/Pinboard"
      #   end
      #
      # @example Subspecs referencing dependencies to other subspecs.
      #
      #   Pod::Spec.new do |s|
      #     s.name = 'RestKit'
      #
      #     s.subspec 'Core' do |cs|
      #       cs.dependency 'RestKit/ObjectMapping'
      #       cs.dependency 'RestKit/Network'
      #       cs.dependency 'RestKit/CoreData'
      #     end
      #
      #     s.subspec 'ObjectMapping' do |os|
      #     end
      #   end
      #
      # @example Nested subspecs.
      #
      #   Pod::Spec.new do |s|
      #     s.name = 'Root'
      #
      #     s.subspec 'Level_1' do |sp|
      #       sp.subspec 'Level_2' do |ssp|
      #       end
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
      #   ---
      #
      #   A Pod should make available the full library by default. Users can
      #   fine tune their dependencies, and exclude unneeded subspecs, once
      #   their requirements are known. Therefore, this attribute is rarely
      #   needed. It is intended to be used to select a default if there are
      #   ‘sub-specifications’ which provide alternative incompatible
      #   implementations, or to exclude modules rarely needed (especially if
      #   they trigger dependencies on other libraries).
      #
      #   @example
      #     spec.default_subspec = 'Pod/Core'
      #
      #   @param  [String] subspec_name
      #           the name of the subspec that should be inherited as
      #           dependency.
      #
      attribute :default_subspec, {
        :multi_platform => false,
      }

      #-----------------------------------------------------------------------#

      # @!group Multi-Platform support
      #
      #   A specification can store values which are specific to only one
      #   platform.
      #
      #   ---
      #
      #   For example one might want to store resources which are specific to
      #   only iOS projects.
      #
      #       spec.resources = "Resources/**/*.png"
      #       spec.ios.resources = "Resources_ios/**/*.png"

      #-----------------------------------------------------------------------#

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
