module Dbsync
  module Importer
    class Base
      def initialize(db_config, local)
        @db_config  = db_config
        @local      = local
      end

      def merge
      end
    end
  end
end
