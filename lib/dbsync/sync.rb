require 'cocaine'

module Dbsync
  class Sync
    class << self
      def notify(message="")
        $stdout.puts "[#{Time.now.strftime('%T')}] [dbsync] #{message}"
      end
    end


    def initialize(ssh_config, db_config, options={})
      ssh_config  = ssh_config.with_indifferent_access
      db_config   = db_config.with_indifferent_access

      @verbose = !!options[:verbose]

      @remote_host  = ssh_config[:remote_host] || raise_missing("remote_host")
      @remote_dir   = ssh_config[:remote_dir]  || raise_missing("remote_dir")
      @local_dir    = ssh_config[:local_dir]   || raise_missing("local_dir")
      @filename     = ssh_config[:filename]    || raise_missing("filename")

      @db_username  = db_config[:username]
      @db_password  = db_config[:password]
      @db_host      = db_config[:host]
      @db_database  = db_config[:database]

      @remote_file = "#{@remote_host}:" + File.join(@remote_dir, @filename)
      @local_file  = File.expand_path(File.join(@local_dir, @filename))
    end


    # Update the local dump file from the remote source (using rsync).
    def fetch
      notify "Updating '#{@local_file}' from '#{@remote_file}' via rsync..."

      line = Cocaine::CommandLine.new('rsync', '-v :remote :local')
      line.run({
        :remote => @remote_file,
        :local  => @local_file
      })
    end


    # Update the local database with the local dump file.
    def merge
      notify "Dumping data from '#{@local_file}' into '#{@db_database}'"

      options = ""
      options += "-u :username " if @db_username.present?
      options += "-p:password "  if @db_password.present?
      options += "-h :host "     if @db_host.present?

      line = Cocaine::CommandLine.new('mysql', "#{options} :database < :local")
      line.run({
        :username   => @db_username,
        :password   => @db_password,
        :host       => @db_host,
        :database   => @db_database,
        :local      => @local_file
      })
    end


    # Update the local dump file, and update the local database.
    def pull
      fetch
      merge
    end


    # Copy the remote dump file to a local destination.
    # This does a full copy (using scp), so it will take longer than
    # fetch (which uses rsync).
    def clone_dump
      notify "Copying '#{@remote_file}' into '#{@local_dir}' via scp..."

      line = Cocaine::CommandLine.new('scp', ':remote :local_dir')
      line.run({
        :remote    => @remote_file,
        :local_dir => @local_dir
      })
    end


    private

    def raise_missing(config="")
      raise "Missing Configuration: '#{config}'. " \
            "See README for required config."
    end

    def notify(*args)
      if @verbose
        Sync.notify(*args)
      end
    end
  end
end
