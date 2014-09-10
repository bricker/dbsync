module Dbsync
  module Strategy
    class Rsync < Base
      BIN = "rsync"

      def fetch
        line = Cocaine::CommandLine.new(BIN, ':bin_opts :remote :local'
          :bin_opts   => @bin_opts,
          :remote     => @remote,
          :local      => @local
        )

        line.run
      end
    end
  end
end
