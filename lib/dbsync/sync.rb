require 'cocaine'
require 'fileutils'

module Dbsync
  class Sync
    STRATEGY = {
      :rsync  => Dbsync::Strategy::Rsync,
      :curl   => Dbsync::Strategy::Curl
    }

    IMPORTER = {
      :mysql => Dbsync::Importer::Mysql
    }


    def initialize(file_config, db_config, options={})
      @file_config  = Dbsync::Util.symbolize_keys(file_config)
      @db_config    = Dbsync::Util.symbolize_keys(db_config)

      @verbose = !!options[:verbose]

      @remote           = @file_config[:remote]
      remote_filename   = File.basename(@remote)

      @local      = File.expand_path(@file_config[:local])
      local_dir   = File.dirname(@local)
      @download   = File.join(local_dir, remote_filename)

      FileUtils.mkdir_p(local_dir)

      @strategy = strategy.new(@remote, @download, @file_config[:bin_opts])
      @importer = importer.new(@db_config, @local)
    end


    # Update the local dump file from the remote source (using rsync).
    def fetch
      notify "Downloading..."
      @strategy.fetch
      extract
    end


    # Update the local database with the local dump file.
    def merge
      notify  "Importing..."
      @importer.merge
    end


    # Update the local dump file, and update the local database.
    def pull
      fetch
      merge
    end


    private

    # TODO: There is a ruby library called "Archive" which can
    # extract these much better for us. The only problem is that
    # we can't specify a *filename* to extract to, which is
    # important for us.
    def extract
      case @download
      when /\.tar/   then untar
      when /\.gz\z/  then gunzip
      end
    end

    # We're overwriting files by default. Is this okay? Probably not.
    def gunzip
      line = Cocaine::CommandLine.new('gunzip', "-c :download > :local",
        download: @download, local: @local)

      line.run
    end

    def untar
      line = Cocaine::CommandLine.new('tar', "-C :local -xf :download",
        download: @download, local: @local)

      line.run
    end


    def importer
      IMPORTER[@file_config[:importer]] ||
      IMPORTER[infer_importer_key]
    end

    def infer_importer_key
      case @db_config[:adapter]
      when /mysql/ then :mysql
      else raise Dbsync::ConfigError, "Only MySQL supported right now."
      end
    end


    def strategy
      STRATEGY[@file_config[:strategy]] ||
      STRATEGY[infer_strategy_key]
    end

    # These matches could be a lot better.
    def infer_strategy_key
      case @remote
      when /\A.+?@.+?:.+?/ then :rsync
      else :curl
      end
    end


    def notify(*args)
      if @verbose
        Dbsync::Util.notify(*args)
      end
    end
  end
end
