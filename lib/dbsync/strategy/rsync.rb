module Dbsync
  module Strategy
    class Rsync < Base
      BIN = "rsync"

      def fetch
        line = Cocaine::CommandLine.new(BIN, ':bin_opts :remote :local')
        line.run({
          :bin_opts   => @bin_opts,
          :remote     => @remote,
          :local      => @local
        })
      end
    end
  end
end
