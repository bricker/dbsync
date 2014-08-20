require 'cocaine'
require 'fileutils'

require "dbsync/version"
require 'dbsync/util'
require "dbsync/strategy"
require "dbsync/importer"
require 'dbsync/sync'

module Dbsync
  class ConfigError < StandardError
  end

  if defined?(Rails)
    class Railtie < Rails::Railtie
      rake_tasks do
        load File.expand_path("dbsync/rake_tasks.rb", __FILE__)
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
