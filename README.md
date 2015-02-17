qwi-download
============

Programs to download and read QWI data (used internally for data at http://download.vrdc.cornell.edu/qwipu/ )

Download of data
-----------

To bulk download the QWI data from the [U.S. Census Bureau](http://lehd.ces.census.gov/data/) website, use the programs in [download-progs](download-progs/), suitably adjusted for your location. See the [README.md](download-progs/README.md) file for more details.

Requirements:
* Linux system
* wget
* about 0.6TB of free storage space

(may work on a OS X system or with Cygwin without modifications)

Readin of data
--------------

Once downloaded, to read in the CSV data files, use the SAS programs in [readin-progs](readin-progs/). The basic readin is adapted from the SAS readin program provided by the Census Bureau with each release, but generalized and streamlined somewhat. Again, the  [README.md](readin-progs/README.md) file has more details. The QWI schema is documented at [the LEHD website (pdf)](http://lehd.ces.census.gov/doc/QWIPU_Data_Schema.pdf) or experimentally in machine-readable form at the [Cornell site](http://download.vrdc.cornell.edu/qwipu.experimental/formats/v4.1b-draft/lehd_public_use_schema.html). 

Requirements
* Linux system
* qsub-compatible job submission system (easy to change)
* SAS
