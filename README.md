# Utility Scripts
A number of utility scripts that do a number of things ;)

Everything is released under MIT Licence for details view ```LICENCE```

## Scripts
### scripts/compress_folders.sh
Compress folder contents and sync archives to (remote) destination (uses rsync and 7z)
> usage: ./compress_folders.sh [-o DIR] [-p] [-c compressdir] [-h] [-d DESTINATION]
> -d -- destination
> -h -- help
> -o -- origin directory
> -p -- propagate deletions

### scripts/conf_backup.sh
Backup conf file provided in cb.conf to destination. With options to unhide
dirs.
> usage: ./conf_backup.sh [-c conf] [-h] [-d DESTINATION]
