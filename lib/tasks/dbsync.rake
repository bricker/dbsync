# Easy database syncing for development/staging

desc "Alias for dbsync:pull"
task :dbsync do
  Rake::Task["dbsync:pull"].invoke
end

namespace :dbsync do
  task :setup => :environment do
    module Dbsync
      LOGGER  = $stdout
      CONFIG  = Rails.application.config.dbsync
      
      CONFIG['remote']  = "#{CONFIG['remote_host']}:" + File.join(CONFIG['remote_dir'], CONFIG['filename'])
      CONFIG['local']   = File.join CONFIG['local_dir'], CONFIG['filename']
    end
    
    # ---------------
    
    Dbsync::LOGGER.puts "Environment: #{Rails.env}"
    
    if Rails.env == 'production'
      raise "These tasks are destructive and shouldn't be used in the production environment."
    end

    #-----------------
    
    if Dbsync::CONFIG['filename'].blank?
      raise "No dump filename specified."
    elsif Dbsync::CONFIG['remote'].blank?
      raise "No remote dump file specified."
    end
    
    #-----------------
    
    VERBOSE = %w{1 true}.include? ENV['VERBOSE']
    DB      = ActiveRecord::Base.configurations[Rails.env]
  end
  
  #-----------------------
  
  desc "Show the dbsync configuration"
  task :config => :setup do
    Dbsync::LOGGER.puts "Config:"
    Dbsync::LOGGER.puts Dbsync::CONFIG.to_yaml
  end
    
  #-----------------------
    
  desc "Update the local dump file, and merge it into the local database"
  task :pull => [:fetch, :merge]
  
  desc "Copy the remote dump file, reset the local database, and load in the dump file"
  task :clone => [:clone_dump, :reset]
  
  #-----------------------
  
  desc "Update the local dump file from the remote source"
  task :fetch => :setup do
    Dbsync::LOGGER.puts "Fetching #{Dbsync::CONFIG['remote']} using rsync"
    output = %x{ rsync -v #{Dbsync::CONFIG['remote']} #{Dbsync::CONFIG['local']} }
    
    if VERBOSE
      Dbsync::LOGGER.puts output
    end
    
    Dbsync::LOGGER.puts "Finished."
  end

  #-----------------------

  desc "Copy the remote dump file to a local destination"
  task :clone_dump => :setup do
    Dbsync::LOGGER.puts "Fetching #{Dbsync::CONFIG['remote']} using scp"
    output = %x{ scp #{Dbsync::CONFIG['remote']} #{Dbsync::CONFIG['local_dir']}/ }
    
    if VERBOSE
      Dbsync::LOGGER.puts output
    end
    
    Dbsync::LOGGER.puts "Finished."
  end

  #-----------------------
  
  desc "Merge the local dump file into the local database"
  task :merge => :setup do
    Dbsync::LOGGER.puts "Dumping data from #{Dbsync::CONFIG['local']} into #{DB['database']}"

    command =  "mysql "
    command += "-u #{DB['username']} " if DB['username'].present?
    command += "-p#{DB['password']} "  if DB['password'].present?
    command += "-h #{DB['host']} "     if DB['host'].present?
    command += "#{DB['database']} < #{Dbsync::CONFIG['local']}"
    
    output = %x{#{command}}
    
    if VERBOSE
      Dbsync::LOGGER.puts output
    end
    
    Dbsync::LOGGER.puts "Finished."
  end

  #-----------------------
  
  desc "Drop & Create the database, then load the dump file."
  task :reset => :setup do
    if VERBOSE
      Dbsync::LOGGER.puts "Resetting database..."
    end
    
    Rake::Task["db:drop"].invoke
    Rake::Task["db:create"].invoke
    Rake::Task["dbsync:merge"].invoke
  end
end
