
module Mixlib
  module CLI
    class Formatter
      # Create a string that includes both versions (short/long) of a flag name
      # based on on whether short/long/both/neither are provided
      #
      # @param short [String] the short name of the option. Can be nil.
      # @param long [String] the long name of the option. Can be nil.
      # @return [String] the formatted flag name as described above
      def self.combined_option_display_name(short, long)
        usage = ""
        # short/long may have an argument (--long ARG)
        # splitting on " " and taking first ensures that we get just
        # the flag name without the argument if one is present.
        usage << short.split(" ").first if short
        usage << "/" if long && short
        usage << long.split(" ").first if long
        usage
      end

      # @param opt_arry [Array]
      #
      # @return [String] a friendly quoted list of items complete with "or"
      def self.friendly_opt_list(opt_array)
        opts = opt_array.map { |x| "'#{x}'" }
        return opts.join(" or ") if opts.size < 3
        opts[0..-2].join(", ") + ", or " + opts[-1]
      end
    end
  end
end
