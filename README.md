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

## recode-pdf.sh
### Requirements
- archive-pdf-tools from internetarchive
- combined hOCR data file for pages
### Description
The script serves as a wrapper around the `recode_pdf` command from the `archive-pdf-tool` package. It automatically adds an hOCR text layer, while `recode_pdf` itself produces a highly compressed Mixed Raster Content (MRC) PDF.
### Prepairing
- create python venv
- activate venv
- `pip install archive-pdf-tools` 

## hocr-combine.sh
### Requirements
- archive-pdf-tools from internetarchive
### Description
The script is a wrapper around the `hocr-combine-stream` command from the `archive-pdf-tool` package.
### Prepairing
- create python venv
- activate venv
- `pip install archive-pdf-tools` 
