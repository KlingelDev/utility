# Utility Scripts
A number of utility scripts that do a number of things ;)

Everything is released under MIT Licence for details view `LICENCE`

## Scripts
### scripts/compress_folders.sh
Compress folder contents and sync archives to (remote) destination (uses rsync and 7z)
```
usage: ./compress_folders.sh [-o DIR] [-p] [-c compressdir] [-h] [-d DESTINATION]
-d -- destination
-h -- help
-o -- origin directory
-p -- propagate deletions
```
### scripts/conf_backup.sh
Backup conf file provided in cb.conf to destination. With options to unhide
dirs.
```
usage: ./conf_backup.sh [-o origin] [-c conf] [-h] [-k compress folder] [-d DESTINATION]
```

Default conf file will be created at `~/.backup_config.conf`
conf_backup.conf should look like this
`u` (unhide) or `h` (keep hidden) `c` (compress) `~/path/to/config` (file or folder)

```
# Options
origin ~
dest ~/Backup/Config
opt keep_depth
compdir ~/.confbackup/compresstmp

# will become DEST/vim
u ~/.vim

# will become DEST/.mutt
h /home/person/.mutt

u ~/.ssh

# Unhide and compress, will become DEST/mozilla.7z
uc ~/.mozilla
```

Configs marked `u` will loose the dot for hiding in destination directory.
