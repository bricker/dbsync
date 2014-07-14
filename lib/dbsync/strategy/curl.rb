module Dbsync
  module Strategy
    class Curl < Base
      BIN = "curl"

      def fetch
        line = Cocaine::CommandLine.new(BIN, ':remote :bin_opts > :local')
        line.run({
          :bin_opts   => @bin_opts,
          :remote     => @remote,
          :local      => @local
        })
      end
    end
  end
end
