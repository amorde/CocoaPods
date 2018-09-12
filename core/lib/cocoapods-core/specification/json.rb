module Pod
  class Specification
    module JSONSupport
      # @return [String] the json representation of the specification.
      #
      def to_json(*a)
        require 'json'
        to_hash.to_json(*a) << "\n"
      end

      # @return [String] the pretty json representation of the specification.
      #
      def to_pretty_json(*a)
        require 'json'
        JSON.pretty_generate(to_hash, *a) << "\n"
      end

      #-----------------------------------------------------------------------#

      # @return [Hash] the hash representation of the specification including
      #         subspecs.
      #
      def to_hash
        hash = attributes_hash.dup
        if root? || available_platforms != parent.available_platforms
          platforms = Hash[available_platforms.map { |p| [p.name.to_s, p.deployment_target && p.deployment_target.to_s] }]
          hash['platforms'] = platforms
        end
        all_appspecs = subspecs.select(&:app_specification?)
        all_testspecs = subspecs.select(&:test_specification?)
        all_subspecs = subspecs.select(&:library_specification?)

        hash['testspecs'] = all_testspecs.map(&:to_hash) unless all_testspecs.empty?
        hash['appspecs'] = all_appspecs.map(&:to_hash) unless all_appspecs.empty?
        hash['subspecs'] = all_subspecs.map(&:to_hash) unless all_subspecs.empty?

        hash
      end
    end

    # Configures a new specification from the given JSON representation.
    #
    # @param  [String] the JSON encoded hash which contains the information of
    #         the specification.
    #
    #
    # @return [Specification] the specification
    #
    def self.from_json(json)
      require 'json'
      hash = JSON.parse(json)
      from_hash(hash)
    end

    # Configures a new specification from the given hash.
    #
    # @param  [Hash] hash the hash which contains the information of the
    #         specification.
    #
    # @param  [Specification] parent the parent of the specification unless the
    #         specification is a root.
    #
    # @return [Specification] the specification
    #
    def self.from_hash(hash, parent = nil, test_specification = false, app_specification = false)
      attributes_hash = hash.dup
      spec = Spec.new(parent, nil, test_specification, :app_specification => app_specification)
      subspecs = attributes_hash.delete('subspecs')
      testspecs = attributes_hash.delete('testspecs')
      appspecs = attributes_hash.delete('appspecs')

      ## backwards compatibility with 1.3.0
      spec.test_specification = !attributes_hash['test_type'].nil?

      testspecs.each { |ts| ts['test_specification'] = true; } unless testspecs.nil?
      appspecs.each { |ts| ts['app_specification'] = true; } unless appspecs.nil?

      spec.attributes_hash = attributes_hash
      spec.subspecs.concat(subspecs_from_hash(spec, subspecs, false, false))
      spec.subspecs.concat(subspecs_from_hash(spec, testspecs, true, false))
      spec.subspecs.concat(subspecs_from_hash(spec, appspecs, false, true))

      spec
    end

    def self.subspecs_from_hash(spec, subspecs, test_specifications, app_specifications)
      return [] if subspecs.nil?
      subspecs.map do |s_hash|
        Specification.from_hash(s_hash, spec, test_specifications, app_specifications)
      end
    end

    #-----------------------------------------------------------------------#
  end
end
