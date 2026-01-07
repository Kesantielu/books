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

## djvu.sh
### Requirements
- cpaldjvu, cjb2, c44, djvumake, djvm from djvulibre
- tifftopnm from netbpm
- identify from imagemagick
### Description
The script accepts a directory, processes scans previously prepared in [Scantailor Advanced](https://github.com/4lex4/scantailor-advanced), then generates a combined djvu.
### Prepairing
- Process the scans in Scantailor Advanced so the `out` folder need to contains subfolders `foreground` and/or `background`
- The script supports Scantailor color segmentation of a page. This page must not contain a full-color layer in the `background` folder.
