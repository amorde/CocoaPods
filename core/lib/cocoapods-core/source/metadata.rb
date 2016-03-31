autoload :Digest, 'digest/md5'

module Pod
  class Source
    class Metadata
      attr_reader :minimum_cocoapods_version
      attr_reader :maximum_cocoapods_version
      attr_reader :latest_cocoapods_version
      attr_reader :prefix_lengths
      attr_reader :last_compatible_versions

      def initialize(hash = {})
        @minimum_cocoapods_version = hash['min']
        @minimum_cocoapods_version &&= Pod::Version.new(@minimum_cocoapods_version)
        @maximum_cocoapods_version = hash['max']
        @maximum_cocoapods_version &&= Pod::Version.new(@maximum_cocoapods_version)
        @latest_cocoapods_version = hash['last']
        @latest_cocoapods_version &&= Pod::Version.new(@latest_cocoapods_version)
        @prefix_lengths = Array(hash['prefix_lengths']).map!(&:to_i)
        @last_compatible_versions = Array(hash['last_compatible_versions']).map(&Pod::Version.method(:new)).sort
      end

      def self.from_file(file)
        hash = file.file? ? YAMLHelper.load_file(file) : {}
        new(hash)
      end

      def path_fragment(pod_name, version = nil)
        prefixes = if prefix_lengths.empty?
                     []
                   else
                     hashed = Digest::MD5.hexdigest(pod_name)
                     prefix_lengths.map do |length|
                       hashed.slice!(0, length)
                     end
                   end
        prefixes.concat([pod_name, version]).compact.join(File::SEPARATOR)
      end

      def last_compatible_version(target_version)
        return unless minimum_cocoapods_version
        return if minimum_cocoapods_version <= target_version
        @last_compatible_versions.reverse_each.bsearch { |v| v <= target_version }.tap do |version|
          raise Informative, 'Unable to find compatible version' unless version
        end
      end

      # Returns whether a source is compatible with the current version of
      # CocoaPods.
      #
      # @param  [Pathname] dir
      #         The directory where the source is stored.
      #
      # @return [Bool] whether the source is compatible.
      #
      def compatible?(version)
        bin_version  = Gem::Version.new(version)
        supports_min = !minimum_cocoapods_version ||
          (bin_version >= Gem::Version.new(minimum_cocoapods_version))
        supports_max = !maximum_cocoapods_version ||
          (bin_version <= Gem::Version.new(maximum_cocoapods_version))
        supports_min && supports_max
      end
    end
  end
end
