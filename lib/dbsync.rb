require "dbsync/version"
require 'dbsync/sync'

module Dbsync
  if defined?(Rails)
    class Railtie < Rails::Railtie
      rake_tasks do
        Dir[File.join(File.dirname(__FILE__),'tasks/*.rake')].each { |f| load f }
      end
    end
  end


  class << self
    def file_config
      @file_config
    end

    def file_config=(config)
      @file_config = config
    end

    def db_config
      @db_config
    end

    def db_config=(config)
      @db_config = config
    end
  end
end
