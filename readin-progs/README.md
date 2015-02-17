QWI Readin programs
===============

The programs here help to read in a large chunk of the QWI CSV programs. Parallelization is achieved by submitting one job per state, where each job reads in multiple files in sequence. A higher amount of parallelization could be achieved by making each file readin a separate job.

Structure
---------
* [sasprogs](sasprogs/) contains the main SAS programs used for the readin.
* [scripts](scripts/) has scripts to generate the qsub readin jobs, which can then be submitted independently as needed.

SAS programs
------------
* Modify [config.template](sasprogs/config.template) to suit your needs, save as config.sas
* Modify [read_in_state_v2.sas](sasprogs/read_in_state_v2.sas) to suit your needs. In particular, the code contains multiple lines such as

      %sas_import_qwi(demotype=&_type.,
        firmtype=&_ftype.,
        seriesid=gs_ns_op_u,
        zip=&zip.,
        csvloc=&importbase./&state./&_type./&_ftype.,
        outputloc=&outbase./&state.);

which are used to readin one specific version of the file. You may want to readin a different file, or less files, or more files.

Scripts
--------
* [create_qsub.bash](scripts/create_qsub.bash) is a ... bash script that creates the qsub programs. Main argument is the release vintage of the QWI (format "R2014Q4"). Configuration of storage locations is hard-coded to the top of the file, you will want to modify that. The generated qsub files are written to scripts/logs directory and perform the following tasks:
    * run SAS (from the sasprogs/ directory), writing to node-specific temporary space (by default, as configured - your config may vary)
    * rsync the file to the final storage location

* [launch_qsub.bash](scripts/launch_qsub.bash) is designed to launch ALL jobs in the current directory (may do some other checks as well if called differently, no longer being actively used).

Alternatively, users can launch qsub jobs manually. 
