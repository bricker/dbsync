require 'cocaine'
require 'fileutils'

module Dbsync
  module Strategy
    class Base
      def initialize(remote, local, bin_opts)
        @remote     = remote
        @local      = local
        @bin_opts   = bin_opts
      end


      # Strategy interface
      # Retrieve the dump file.
      def fetch
      end
    end
  end
end
