# dbsync

A set of rake tasks to help you sync your production 
data with your local database for development.

Currently only supports:
* Rails
* MySQL

Support for more things will happen if anybody needs it.

## Usage

Add to your gemfile in the `development` group:

    group :development do
      gem 'dbsync'
    end
    
Add the following to your `config/environments/development.rb` 
file. Depending on your staging setup, it may also be useful 
to you to add some `dbsync` config to your `staging.rb` 
environment file. **Note** `dbsync` will not run in production.

    config.dbsync = ActiveSupport::OrderedOptions.new

    config.dbsync.filename    = "yourapp_production_data.dump" # The name of the remote dumpfile
    config.dbsync.local_dir   = "#{Rails.root}/../dbsync"      # The local directory to store the dump file. No trailing slash
    config.dbsync.remote_host = "66.123.4.567"                 # Remote server where the dumpfile is
    config.dbsync.remote_dir  = "~dbsync"                      # The directory on the remote server where the dumpfile is

Now just make sure you have something on the remote 
server updating that dumpfile. I recommend a cronjob:

    0 */12 * * * /usr/bin/mysqldump yourapp_production > /home/dbsync/yourapp_production_data.dump


You will need proper SSH access into the remote server, 
as the tasks use `rsync` and `scp` directly.

Run `rake -T dbsync` for all of the available tasks. The 
tasks are named after `git` commands mostly, so they
should be pretty straight-forward for those who use `git`:

    rake dbsync             # Alias for dbsync:pull
    rake dbsync:clone       # Copy the remote dump file, reset the local database, and load in the dump file
    rake dbsync:clone_dump  # Copy the remote dump file to a local destination
    rake dbsync:config      # Show the dbsync configuration
    rake dbsync:fetch       # Update the local dump file from the remote source
    rake dbsync:merge       # Merge the local dump file into the local database
    rake dbsync:pull        # Update the local dump file, and merge it into the local database
    rake dbsync:reset       # Drop & Create the database, then load the dump file.
    
### TODO

- Specs!

### Copyright

Copyright (c) 2012 Bryan Ricker/SCPR.

### Licence

See MIT-LICENSE for more.
