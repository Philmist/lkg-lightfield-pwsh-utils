# Scripts for making Lightfields

Scripts for my own use.

Some scripts needs ffmpeg.

## `lightfield` directory

Main scripts.

### `copyTime.lua`

A script for mpv.
Copy a time range to the clipboard in the format `-ss 0:00 -to 0:00` when you press CTRL+C and release it.
It is suitable for ffmpeg.

Derived from [mpv-copyTime](https://github.com/Arieleg/mpv-copyTime).

### `_make_framesmkv.ps1`

A script to create a movie that contains time as `00.0000`(sec) format.
This script transposes a source movie clock.

This script needs ffmpeg.

### `_slice_to_lf_images.ps1`

A script to create lightfield photoset from a movie file.

Example:
`.\_slice_to_lf_images.ps1 -ss 37.149 -to 38.533 -i .\test.mkv -d test`

This command invokes the script which creates a directory named `test` and cuts the movie from 37.149 sec to 38.533 sec. It outputs images to `test`.

Note that the default is to rotate the video clockwise.
You can change it with `-transpose` option.

## `depthimage` directory

### `_concat_depthimage.ps1`

A utility script for concating original image with depth image.

## `HoloPlayStudio` directory

### `Switch-Playlist.ps1`

A script for switching playlists.

The default playlist must be named `New Playlist____`.
Others is named like `New Playlist____other`.

Examples:
`.\Switch-Playlist.ps1`

This command creates the junction called `New Playlist` which will point to `New Playlist____`.
If the junction has already been created, these scripts will delete it.

`.\Switch-Playlist.ps1 other`

This command creates the junction which will point to `New Playlist____other`.
If the junction has already been created, these scripts will delete it.

# LICENSE

See `LICENSE` file.

