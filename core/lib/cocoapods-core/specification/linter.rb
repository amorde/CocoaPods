require 'cocoapods-core/specification/linter/result'
require 'cocoapods-core/specification/linter/analyzer'

module Pod
  class Specification
    # The Linter check specifications for errors and warnings.
    #
    # It is designed not only to guarantee the formal functionality of a
    # specification, but also to support the maintenance of sources.
    #
    class Linter
      include ResultHelpers

      # @return [Specification] the specification to lint.
      #
      attr_reader :spec

      # @return [Pathname] the path of the `podspec` file where {#spec} is
      #         defined.
      #
      attr_reader :file

      # @param  [Specification, Pathname, String] spec_or_path
      #         the Specification or the path of the `podspec` file to lint.
      #
      def initialize(spec_or_path)
        if spec_or_path.is_a?(Specification)
          @spec = spec_or_path
          @file = @spec.defined_in_file
        else
          @file = Pathname.new(spec_or_path)
          begin
            @spec = Specification.from_file(@file)
          rescue Exception => e
            @spec = nil
            @raise_message = e.message
          end
        end
      end

      # Lints the specification adding a {Result} for any failed check to the
      # {#results} list.
      #
      # @return [Bool] whether the specification passed validation.
      #
      def lint
        @results = []
        if spec
          check_required_root_attributes
          run_root_validation_hooks
          perform_all_specs_analysis
        else
          error "[spec] The specification defined in `#{file}` could not be" \
          ' loaded.' \
            "\n\n#{@raise_message}"
        end
        results.empty?
      end

      #-----------------------------------------------------------------------#

      # !@group Lint results

      public

      # @return [Array<Result>] all the errors generated by the Linter.
      #
      def errors
        @errors ||= results.select { |r| r.type == :error }
      end

      # @return [Array<Result>] all the warnings generated by the Linter.
      #
      def warnings
        @warnings ||= results.select { |r| r.type == :warning }
      end

      #-----------------------------------------------------------------------#

      private

      # !@group Lint steps

      # Checks that every root only attribute which is required has a value.
      #
      # @return [void]
      #
      def check_required_root_attributes
        attributes = DSL.attributes.values.select(&:root_only?)
        attributes.each do |attr|
          value = spec.send(attr.name)
          next unless attr.required?
          unless value && (!value.respond_to?(:empty?) || !value.empty?)
            if attr.name == :license
              warning("[attributes] Missing required attribute `#{attr.name}`.")
            else
              error("[attributes] Missing required attribute `#{attr.name}`.")
            end
          end
        end
      end

      # Runs the validation hook for root only attributes.
      #
      # @return [void]
      #
      def run_root_validation_hooks
        attributes = DSL.attributes.values.select(&:root_only?)
        run_validation_hooks(attributes, spec)
      end

      # Run validations for multi-platform attributes activating .
      #
      # @return [void]
      #
      def perform_all_specs_analysis
        all_specs = [spec, *spec.recursive_subspecs]
        all_specs.each do |current_spec|
          current_spec.available_platforms.each do |platform|
            @consumer = Specification::Consumer.new(current_spec, platform)
            run_all_specs_validation_hooks
            analyzer = Analyzer.new(@consumer)
            analyzer.analyze
            add_results(analyzer.results)
            @consumer = nil
          end
        end
      end

      # @return [Specification::Consumer] the current consumer.
      #
      attr_accessor :consumer

      # Runs the validation hook for the attributes that are not root only.
      #
      # @return [void]
      #
      def run_all_specs_validation_hooks
        attributes = DSL.attributes.values.reject(&:root_only?)
        run_validation_hooks(attributes, consumer)
      end

      # Runs the validation hook for each attribute.
      #
      # @note   Hooks are called only if there is a value for the attribute as
      #         required attributes are already checked by the
      #         {#check_required_root_attributes} step.
      #
      # @return [void]
      #
      def run_validation_hooks(attributes, target)
        attributes.each do |attr|
          validation_hook = "_validate_#{attr.name}"
          next unless respond_to?(validation_hook, true)
          value = target.send(attr.name)
          next unless value
          send(validation_hook, value)
        end
      end

      #-----------------------------------------------------------------------#

      private

      # @!group Root spec validation helpers

      # Performs validations related to the `name` attribute.
      #
      def _validate_name(n)
        if spec.name && file
          acceptable_names = [
            spec.root.name + '.podspec',
            spec.root.name + '.podspec.json',
          ]
          names_match = acceptable_names.include?(file.basename.to_s)
          unless names_match
            error '[name] The name of the spec should match the name of the \
                    file.'
          end

          if spec.root.name =~ /\s/
            error '[name] The name of a spec should not contain whitespace.'
          end

          if spec.root.name[0, 1] == '.'
            error '[name] The name of a spec should not begin with a period.'
          end
        end
      end

      def _validate_version(v)
        if v.to_s.empty?
          error '[version] A version is required.'
        elsif v <= Version::ZERO
          error '[version] The version of the spec should be higher than 0.'
        end
      end

      # Performs validations related to the `summary` attribute.
      #
      def _validate_summary(s)
        if s.length > 140
          warning '[summary] The summary should be a short version of' \
          '`description` (max 140 characters).'
        end
        if s =~ /A short description of/
          warning '[summary] The summary is not meaningful.'
        end
      end

      # Performs validations related to the `description` attribute.
      #
      def _validate_description(d)
        if d =~ /An optional longer description of/
          warning '[description] The description is not meaningful.'
        end
        if d == spec.summary
          warning '[description] The description is equal to the summary.'
        end
        if d.length < spec.summary.length
          warning '[description] The description is shorter than the summary.'
        end
      end

      # Performs validations related to the `homepage` attribute.
      #
      def _validate_homepage(h)
        if h =~ %r{http://EXAMPLE}
          warning '[homepage] The homepage has not been updated from default'
        end
      end

      # Performs validations related to the `frameworks` attribute.
      #
      def _validate_frameworks(frameworks)
        if frameworks_invalid?(frameworks)
          error '[frameworks] A framework should only be specified by its name'
        end
      end

      # Performs validations related to the `weak frameworks` attribute.
      #
      def _validate_weak_frameworks(frameworks)
        if frameworks_invalid?(frameworks)
          error '[weak_frameworks] A weak framework should only be specified' \
          'by its name'
        end
      end

      # Performs validations related to the `libraries` attribute.
      #
      def _validate_libraries(libs)
        libs.each do |lib|
          lib = lib.downcase
          if lib.end_with?('.a') || lib.end_with?('.dylib')
            error '[libraries] Libraries should not include the extension ' \
            "(`#{lib}`)"
          end

          if lib.start_with?('lib')
            error '[libraries] Libraries should omit the `lib` prefix' \
            " (`#{lib}`)"
          end

          if lib.include?(',')
            error '[libraries] Libraries should not include comas' \
            "(`#{lib}`)"
          end
        end
      end

      # Performs validations related to the `license` attribute.
      #
      def _validate_license(l)
        type = l[:type]
        if type.nil?
          warning '[license] Missing license type.'
        end
        if type && type.gsub(' ', '').gsub("\n", '').empty?
          warning '[license] Invalid license type.'
        end
        if type && type =~ /\(example\)/
          error '[license] Sample license type.'
        end
      end

      # Performs validations related to the `source` attribute.
      #
      def _validate_source(s)
        if git = s[:git]
          tag, commit = s.values_at(:tag, :commit)
          version = spec.version.to_s

          if git =~ %r{http://EXAMPLE}
            error '[source] The Git source still contains the example URL.'
          end
          if commit && commit.downcase =~ /head/
            error '[source] The commit of a Git source cannot be `HEAD`.'
          end
          if tag && !tag.to_s.include?(version)
            warning '[source] The version should be included in the Git tag.'
          end
          if version == '0.0.1'
            if commit.nil? && tag.nil?
              error '[source] Git sources should specify either a commit or' \
              'a tag.'
            end
          else
            warning '[source] Git sources should specify a tag.' if tag.nil?
          end
        end

        perform_github_source_checks(s)
        check_git_ssh_source(s)
      end

      # Performs validations related to github sources.
      #
      def perform_github_source_checks(s)
        require 'uri'

        if git = s[:git]
          return unless git =~ /^#{URI.regexp}$/
          git_uri = URI.parse(git)
          if git_uri.host == 'www.github.com'
            warning '[github_sources] Github repositories should not use' \
            '`www` in URL.'
          end
          if git_uri.host == 'github.com' || git_uri.host == 'gist.github.com'
            unless git.end_with?('.git')
              warning '[github_sources] Github repositories should end in' \
              '`.git`.'
            end
            unless git_uri.scheme == 'https'
              warning '[github_sources] Github repositories should use' \
              '`https` link.'
            end
          end
        end
      end

      # Performs validations related to SSH sources
      #
      def check_git_ssh_source(s)
        if git = s[:git]
          if git =~ /\w+\@(\w|\.)+\:(\/\w+)*/
            warning '[source] Git SSH URLs will NOT work for people behind' \
              'firewalls configured to only allow HTTP, therefor HTTPS is' \
              'preferred.'
          end
        end
      end

      # Performs validations related to the `social_media_url` attribute.
      #
      def _validate_social_media_url(s)
        if s =~ %r{https://twitter.com/EXAMPLE}
          warning '[social_media_url] The social media URL has not been' \
          'updated from default'
        end
      end

      #-----------------------------------------------------------------------#

      # @!group All specs validation helpers

      private

      # Performs validations related to the `compiler_flags` attribute.
      #
      def _validate_compiler_flags(flags)
        if flags.join(' ').split(' ').any? { |flag| flag.start_with?('-Wno') }
          warning '[compiler_flags] Warnings must not be disabled' \
          '(`-Wno compiler` flags).'
        end
      end

      # Returns whether the frameworks are valid
      #
      # @param frameworks [Array<String>]
      # The frameworks to be validated
      #
      # @return [Boolean] true if a framework contains any
      # non-alphanumeric character or includes an extension.
      #
      def frameworks_invalid?(frameworks)
        frameworks.any? do |framework|
          framework_regex = /[^\w\-\+]/
          framework =~ framework_regex
        end
      end
    end
  end
end
