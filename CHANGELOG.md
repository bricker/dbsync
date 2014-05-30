## 0.3.0
* Removed all Rails dependencies. Rails is now optional.
* Removed scp usage. Everything uses rsync now.
* Added Dbsync.file_config and Dbsync.db_config to manually set configuration.
* [DEPRECATED] local_dir, remote_dir, remote_host, filename options. Instead, combine them into just `local` and `remote` configurations (see README for more).

## 0.2.0 (2014-02-13)
* Internal refactoring.
* Updated gem dependencies.
