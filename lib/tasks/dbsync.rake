# Easy database syncing for development/staging

desc "Alias for dbsync:pull"
task :dbsync do
  Rake::Task['dbsync:pull'].invoke
end

namespace :dbsync do
  task :setup => :environment do
    Dbsync::Sync.notify "Environment: #{Rails.env}"

    if Rails.env == 'production'
      raise "These tasks are destructive and shouldn't " \
            "be used in the production environment."
    end

    @dbsync = Dbsync::Sync.new(
      Rails.application.config.dbsync,
      ActiveRecord::Base.configurations[Rails.env],
      verbose: true
    )
  end


  desc "Show the dbsync configuration"
  task :config => :setup do
    # We don't use Sync.notify here because we don't want or need
    # the extra output that comes with it.
    $stdout.puts Rails.application.config.dbsync.to_yaml
  end


  desc "Update the local dump file, and merge it into the local database"
  task :pull => :setup do
    @dbsync.pull
  end


  desc  "Copy the remote dump file, reset the local database, " \
        "and load in the dump file"
  task :clone => :setup do
    @dbsync.clone_dump
    Rake::Task['dbsync:reset'].invoke
  end


  desc "Update the local dump file from the remote source."
  task :fetch => :setup do
    @dbsync.fetch
  end


  desc "Copy the remote dump file to a local destination"
  task :clone_dump => :setup do
    @dbsync.clone_dump
  end


  desc "Update the local database with the local dump file."
  task :merge => :setup do
    @dbsync.merge
  end


  desc "Drop and Create the database, then load the dump file."
  task :reset => :setup do
    Rake::Task["db:drop"].invoke
    Rake::Task["db:create"].invoke
    @dbsync.merge
  end
end
