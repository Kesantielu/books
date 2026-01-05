# books
Scripts for books processing

## average_dpi.sh
### Requirements
- exiftool
### Description

The script accepts a directory path and, for each of its subfolders:
- searches for *.jpg files,
- extracts the DPI (XResolution tag) from them using exiftool,
- calculates and displays the average DPI value.

