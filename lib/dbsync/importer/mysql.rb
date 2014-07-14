module Dbsync
  module Importer
    class Mysql < Base
      def merge
        username  = @db_config[:username]
        password  = @db_config[:password]
        host      = @db_config[:host]
        database  = @db_config[:database]

        opts = ""
        opts += "-u :username " if username
        opts += "-p:password "  if password
        opts += "-h :host "     if host

        line = Cocaine::CommandLine.new('mysql', "#{opts} :database < :local")
        line.run({
          :username   => username,
          :password   => password,
          :host       => host,
          :database   => database,
          :local      => @local
        })
      end
    end
  end
end
