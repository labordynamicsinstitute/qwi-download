QWI download programs
=====================

The programs in this directory are used to manage a recurring bulk download from the  [U.S. Census Bureau](http://lehd.ces.census.gov/data/) website.

Main programs
-------------
* [qwi_download_state9.sh](qwi_download_state9.sh): Main program, downloads specific files for a single state
* [qwi_download_all8.sh](qwi_download_all8.sh): Calls the previous program, for all states and types of files
* [qwi_check_complete.sh](qwi_check_complete.sh): Used to check completeness
* [check_status.sh](check_status.sh): Also used to check completeness. Just different.

Other programs
--------------
These other programs may have served a need once, but are no longer actively used.
* [qwi_download_reverse.sh](qwi_download_reverse.sh): I forget
* [qwi_download_test.sh](qwi_download_test.sh): Tests something
* [qwi_rezip_types.sh](qwi_rezip_types.sh): QWI files are compressed using gzip. This goes through all data files, and recompresses using bzip for greater compression ratios.
* [qwi_rebzip_types.sh](qwi_rebzip_types.sh): Early Cornell versions of files were compressed using the parallel version of bzip ([pbzip](http://compression.ca/pbzip2/)). It turns out that most users use [WinZip](http://www.winzip.com) to decompress files, and that program does not fully implement the bzip compression standard, and fails when files are compressed using pbzip. This program goes through all data files, and recompresses using (non-parallel) bzip for better compatability.
* [qwi_download_state8.sh](qwi_download_state8.sh): Older version of download program (older file structure) 
