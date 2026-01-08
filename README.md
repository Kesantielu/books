# books
Scripts for books processing

## average_dpi.sh
### Requirements
- exiftool
### Description
The script accepts a directory path and, for each of its subfolders:
- Searches for `*.jpg` files  
- Extracts the DPI (XResolution tag) from each file using **exiftool**  
- Calculates and displays the average DPI value

## djvu.sh
### Requirements
- cpaldjvu, cjb2, c44, djvumake, djvm from djvulibre
- tifftopnm from netbpm
- identify from imagemagick
### Description
The script takes a directory as input, processes scans previously prepared in [Scantailor Advanced](https://github.com/4lex4/scantailor-advanced), and generates a combined DjVu file.
### Preparing
- Process the scans in Scantailor Advanced so that the `out` folder contains the subfolders `foreground` and/or `background`.
- The script supports Scantailor’s page color segmentation. A segmented page must not include a full‑color layer in the `background` folder.

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

## grk-pdf.sh
## Requirements
- grk_compress from grokj2k-tools
### Description
The script is a wrapper around the `grk_compress` command from the ` grokj2k-tools` package. It generates high quality PDF by default
