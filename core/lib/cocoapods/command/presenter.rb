module Pod
  class Command
    class Presenter
      def self.options
        "    --stats     Show additional stats (like GitHub watchers and forks)\n"
      end

      def initialize(argv)
        @stats = argv.option('--stats')
      end

      def present_sets(array)
        puts
        array.each {|set| present_set(set)}
      end

      def present_set(set)
        stats = Pod::Specification::Statistics.new(set)
        puts "--> #{set.name} (#{set.versions.reverse.join(", ")})".green
        puts wrap_string(stats.summary)
        puts_detail('Homepage', stats.homepage)
        puts_detail('Source',   stats.source_url)
        puts_detail('Watchers', stats.github_watchers) if @stats
        puts_detail('Forks',    stats.github_forks)    if @stats
        puts
      end

      # adapted from http://blog.macromates.com/2006/wrapping-text-with-regular-expressions/
      def wrap_string(txt, col = 80, indentation = 4)
        indent = ' ' * indentation
        txt.strip.gsub(/(.{1,#{col}})( +|$)\n?|(.{#{col}})/, indent + "\\1\\3\n")
      end

      def puts_detail(title, string, preferred_indentation = 8)
        # 8 is the length of Homepage
        return if !string
        number_of_spaces = ((preferred_indentation - title.length) > 0) ? (preferred_indentation - title.length) : 0
        spaces = ' ' * number_of_spaces
        puts "    - #{title}: #{spaces + string}"
      end
    end
  end
end
