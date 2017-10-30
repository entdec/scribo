# Importing and exporting

Scribo allows you to easily import and export sites, 
if you want to work with the content outside the maintenance.

Importing and exporting is done using zip files, which contains one zipped site.

## Meta information 
The zip-files are annotated using zip-comments, which contain meta information encoded as JSON.

You can see the meta information with `unzip -l site_untitled.zip`

## Using the exported ZIP

You don't want to completely create a new zip, this way you will lose meta information.
Instead it's best to update the zip, which is done as follows: `zip -ur site_untitled.zip site_untitled`

