# How to (potentially) recover video files from a formatted SD card

Fork of [mf-mesh-](https://github.com/bradsk88/mf-mesh-) which moves file discovery features from Python to the shell.

Ideally, you *just* formatted the card.  If you've used the card since formatting,
there is a risk that your data is gone forever.

To reduce the risk of further loss (and in general) I would recommend making an 
image of your SD card before proceeding (optional)

On linux you can run this command, assuming your SD card is loaded at `/dev/sd`:
```
dd if=/dev/sd of=~/mybackup.img --progress
```

Once you have an image file, run [photorec](https://wiki.archlinux.org/index.php/file_recovery#Testdisk_and_PhotoRec)
to recover any .mov files from `mybackup.img`.

Once that's finished, **you should have many `_ftyp.mov` and `_mdat.mov` files. 
These are the data from your videos, but they need to be paired up before you 
can use the videos.  Problem is: they don't appear to pair up in any particular 
order.**

Copy `ftyp_mdat_recovery.sh` from this repo into the folder with all of the `_ftyp/mdat` 
and run it (you need ffpmeg):

```
$ ./ftyp_mdat_recovery.sh.py
```

This will run a brute-force algorithm to pair up every combination of 
`ftyp/mdat` files in the directory and attempt to generate a screenshot from them.  *This will take a very long time*. Compared to the upstream [mf-mesh-](https://github.com/bradsk88/mf-mesh-), this will use FAR less disk space as combinations are checked with ffmpeg and removed if invalid. See `DO_CLEANUP` option at the top of the script.

There are two flags located at the top of the `ftyp_mdat_recovery.sh` file. `DEBUG` controls the verbosity of stdout. `DO_CLEANUP` determines whether or not to delete combinations that have failed. 
