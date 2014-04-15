# dbsync

A set of rake tasks to help you sync your production data with your local database for development. **Currently only supports MySQL.**

## Usage

Add to your gemfile for the groups that will need it:

```ruby
group :development, :staging do
  gem 'dbsync'
end
```

Or just install it as a gem:

```
gem install dbsync
```

### For Rails

Add the following to your `config/environments/development.rb` file. Depending on your staging setup, it may also be useful to you to add some `dbsync` config to your `staging.rb` environment file. **`dbsync` will not run in production.**

```ruby
config.dbsync = {
  :remote => '66.123.4.567:~/dbsync/mydb.dump',
  :local  => '../dbsync/mydb.dump'
}
```

Dbsync will automatically use your Rails environment's database configuration.

### For non-Rails

You can also specify the dbsync configuration with `Dbsync.file_config` and `Dbsync.db_config`:

```ruby
Dbsync.file_config = {
  :local => "../dbsync/dbsync.dump",
  :remote => "dbuser@100.0.100.100:~dbuser/dbsync.dump"
}

Dbsync.db_config = {
  :adapter  => "mysql2", # Not actually used yet
  :database => "yourdb",
  :username => "youruser",
  :password => "yourcoolpassword"
}
```

### The server

Now just make sure you have something on the remote server updating that dumpfile. I recommend a cronjob:

```
0 */12 * * * /usr/bin/mysqldump yourapp_production > /home/dbsync/yourapp_production_data.dump
```

If you are using the SSH form of rsync, you will need proper SSH access into the remote server.

### Rake

Run `rake -T dbsync` for all of the available tasks. The tasks are named after `git` commands mostly, so they should be pretty straight-forward for those who use `git`:

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
* Rails: the test database isn't automatically updated when syncing to your development database. After a `dbsync` and before you run tests, you'll need to run `rake db:test:prepare` to setup your database.
* Rails: your schema.rb isn't involed in `dbsync` at all. You need to manage it yourself.


### TODO

- Support postgres, sqlite, and anything else.


### Feedback/Support

Open an issue or send a pull request.
