require 'cocaine'
require 'fileutils'

module Dbsync
  class Sync
    class << self
      def notify(message="")
        $stdout.puts "[#{Time.now.strftime('%T')}] [dbsync] #{message}"
      end
    end


    def initialize(ssh_config, db_config, options={})
      ssh_config  = symbolize_keys(ssh_config)
      db_config   = symbolize_keys(db_config)

      @verbose = !!options[:verbose]

      @db_username  = db_config[:username]
      @db_password  = db_config[:password]
      @db_host      = db_config[:host]
      @db_database  = db_config[:database]

      @remote   = ssh_config[:remote]
      @local    = File.expand_path(ssh_config[:local]) if ssh_config[:local]

      if !@remote
        $stdout.puts "DEPRECATED: The remote_host, remote_dir, and filename " \
          "options will be removed. " \
          "Instead, combine remote_host, remote_dir, and filename into a " \
          "single 'remote' configuration. Example: " \
          "'{ remote: \"dbuser@100.0.1.100:~/dbuser/yourdb.dump\" }'"

        remote_host = ssh_config[:remote_host]
        remote_dir  = ssh_config[:remote_dir]
        filename    = ssh_config[:filename]
        @remote = "#{remote_host}:#{File.join(remote_dir, filename)}"
      end

      if !@local
        $stdout.puts "DEPRECATED: The local_dir and filename " \
          "options will be removed. " \
          "Instead, combine local_dir and filename into a " \
          "single 'local' configuration. Example: " \
          "'{ local: \"../dbsync/yourdb.dump\" }'"

        local_dir = ssh_config[:local_dir]
        filename  = ssh_config[:filename]
        @local  = File.expand_path(File.join(local_dir, filename))
      end
    end


    # Update the local dump file from the remote source (using rsync).
    def fetch
      notify "Updating '#{@local}' from '#{@remote}' via rsync..."

      FileUtils.mkdir_p(File.dirname(@local))

      line = Cocaine::CommandLine.new('rsync', '-v :remote :local')
      line.run({
        :remote => @remote,
        :local  => @local
      })
    end


    # Update the local database with the local dump file.
    def merge
      notify "Dumping data from '#{@local}' into '#{@db_database}'..."

      options = ""
      options += "-u :username " if @db_username
      options += "-p:password "  if @db_password
      options += "-h :host "     if @db_host

      line = Cocaine::CommandLine.new('mysql', "#{options} :database < :local")
      line.run({
        :username   => @db_username,
        :password   => @db_password,
        :host       => @db_host,
        :database   => @db_database,
        :local      => @local
      })
    end


    # Update the local dump file, and update the local database.
    def pull
      fetch
      merge
    end


    # Copy the remote dump file to a local destination.
    # Instead of requiring two different tools (rsync and scp) for this
    # library, instead we'll just remove the local file if it exists
    # then run rsync, which is essentially a full copy.
    def clone_dump
      notify "Copying '#{@remote}' into '#{@local}' via rsync..."
      FileUtils.rm_f(@local)
      fetch
    end


    private

    def symbolize_keys(hash)
      return hash unless hash.keys.any? { |k| k.is_a?(String) }

      result = {}
      hash.each_key { |k| result[k.to_sym] = hash[k] }
      result
    end


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
