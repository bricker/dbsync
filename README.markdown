# dbsync

A set of rake tasks to help you sync your production 
data with your local database for development.

Currently only supports MySQL. The Rake tasks are written for Rails-only,
but the Sync class can be used with ruby framework, as long as you pass in the
correct database configuration.

Support for more things will happen if anybody needs it.


## Usage

Add to your gemfile for the groups that will need it:

```ruby
group :development, :staging do
  gem 'dbsync'
end
```

Add the following to your `config/environments/development.rb` 
file. Depending on your staging setup, it may also be useful 
to you to add some `dbsync` config to your `staging.rb` 
environment file. **Note** `dbsync` will not run in production.

```ruby
config.dbsync = {
  :filename    => "yourapp_production_data.dump", # The name of the remote dumpfile.
  :local_dir   => "#{Rails.root}/../dbsync",   # The local directory to store the dump file.
  :remote_host => "66.123.4.567",              # Remote server where the dumpfile is located.
  :remote_dir  => "~dbsync"                    # The directory on the remote server where the dumpfile is.
}
```

Now just make sure you have something on the remote 
server updating that dumpfile. I recommend a cronjob:

    0 */12 * * * /usr/bin/mysqldump yourapp_production > /home/dbsync/yourapp_production_data.dump


You will need proper SSH access into the remote server, 
as the tasks use `rsync` and `scp` directly.

Run `rake -T dbsync` for all of the available tasks. The 
tasks are named after `git` commands mostly, so they
should be pretty straight-forward for those who use `git`:

```
rake dbsync             # Alias for dbsync:pull
rake dbsync:clone       # Copy the remote dump file, reset the local database, and load in the dump file
rake dbsync:clone_dump  # Copy the remote dump file to a local destination
rake dbsync:config      # Show the dbsync configuration
rake dbsync:fetch       # Update the local dump file from the remote source
rake dbsync:merge       # Update the local database with the local dump file
rake dbsync:pull        # Update the local dump file, and merge it into the local database
rake dbsync:reset       # Drop and Create the database, then load the dump file
```


### Caveats

* The `merge` process doesn't clear out your database first. This is to improve performance. Therefore, any tables which you removed on the remote host won't be removed locally. To do a complete reset of your database, run `rake dbsync:reset`. This resets your database (`db:drop` and `db:create`), and then merges in the local file.
* The test database isn't automatically updated when syncing to your development database. After a `dbsync` and before you run tests, you'll need to run `rake db:test:prepare` to setup your database.
* Your schema.rb isn't involed in `dbsync` at all. You need to manage it yourself.


### TODO

- Support postgres, sqlite, and anything else.


### Copyright

Copyright (c) 2012 Bryan Ricker/SCPR.

### Licence

See MIT-LICENSE for more.
