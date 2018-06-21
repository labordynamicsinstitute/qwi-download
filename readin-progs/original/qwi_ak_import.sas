/* Description: Used to help create the qwi_&state_import.sas program.                 */
/*=====================================================================================*/

/*
** IMPORT QWI CSV FILES INTO SAS DATASETS **;


INSTRUCTIONS:

This program can be used to read in all QWI CSV files into a single SAS data table.  The list of all QWI CSV files
available in this release can be found following the DATALINES statement at the end of this program.
The location (full or relative path) of the CSV files should be specified in the dataloc macro variable, below.
The output SAS table will be placed in the OUTPUTS library, specified in the outputloc macro variable.
There are also a set of formats that are created for the categorical variables, which will be placed in a format 
catalog in the same directory.

If only selected data tables have been downloaded, a warning will be issued for the files which are not available.
All available tables will be read into the data table.

This program uses the PIPE clause in the infile statement, which does not require unzipping the input file first.  This functionality
should be available on SAS for UNIX platforms.  When executing this on other platforms, the following additional steps may be required:

1) Decompress the input files using external software
2) Replace the word PIPE with a blank space in the assignment of the unixpipe macro variable.



The user also has the option of including data labels for all categorical variables.  These will be generated using the formats.
This functiontality is commented out by default.


*/


options nocenter;

%let dataloc=.;
%let outputloc=&dataloc/outputs;
%let unixpipe=PIPE;

libname OUTPUTS "&outputloc";
libname  LIBRARY "&outputloc";


** generate formats from csv files **;
data fmts;
	length myinfile $300;
	input myinfile;
	length start $20 label $300 fmtname $8;
	myinfile_full="&dataloc" || '/'||myinfile;
	infile stuff filevar=myinfile_full firstobs=2 dsd dlm=',' end=done ;
	do while (not done);
		input start label;
		** the format name is the first seven characters of the file name **;
		fmtname='$'||substr(scan(myinfile,1),7);
		output;
	end;
datalines;
label_periodicity.csv
label_seasonadj.csv
label_geo_level.csv
label_geography.csv
label_ind_level.csv
label_industry.csv
label_ownercode.csv
label_sex.csv
label_agegrp.csv
label_race.csv
label_ethnicity.csv
label_education.csv
label_firmage.csv
label_firmsize.csv
;
proc sort data=fmts nodups;
	by fmtname start;
run;
proc format cntlin=fmts library=LIBRARY;
proc format fmtlib library=LIBRARY;
	select :;
quit;

**  The following data step appends all csv files into a single SAS data table;
data OUTPUTS.qwi_data (drop=myinfile: avail);
	infile datalines;
	length myinfile $300;
	input myinfile;
	** check if file has been decompressed already **;
	if fileexist("&dataloc./" || myinfile) then avail=1;
	else if fileexist("&dataloc./" || substr(myinfile,1,index(myinfile,'.gz')-1)) then avail=2;
	else avail=0;
	if avail=0 then  put "WARNING: the following input is not available - " myinfile;
	else do;
		** zipped file readin using pipe **;
		if avail=1 then do;
			myinfile_full="gunzip -c &dataloc./" || myinfile;
		end;
		** unzipped file readin **;
		else do;
			myinfile=substr(myinfile,1,index(myinfile,'.gz')-1);
			myinfile_full="&dataloc./" || myinfile;
		end;
		infile stuff &unixpipe. filevar=myinfile_full firstobs=2 dsd dlm=',' lrecl=32767 end=done ;
		do while (not done);
			informat
periodicity $1.
seasonadj $1.
geo_level $1.
geography $8.
ind_level $1.
industry $5.
ownercode $3.
sex $1.
agegrp $3.
race $2.
ethnicity $2.
education $2.
firmage $1.
firmsize $1.
year best32.
quarter best32.
Emp best32.
EmpEnd best32.
EmpS best32.
EmpTotal best32.
EmpSpv best32.
HirA best32.
HirN best32.
HirR best32.
Sep best32.
HirAEnd best32.
SepBeg best32.
HirAEndRepl best32.
HirAEndR best32.
SepBegR best32.
HirAEndReplR best32.
HirAS best32.
HirNS best32.
SepS best32.
SepSnx best32.
TurnOvrS best32.
FrmJbGn best32.
FrmJbLs best32.
FrmJbC best32.
FrmJbGnS best32.
FrmJbLsS best32.
FrmJbCS best32.
EarnS best32.
EarnBeg best32.
EarnHirAS best32.
EarnHirNS best32.
EarnSepS best32.
Payroll best32.
sEmp best32.
sEmpEnd best32.
sEmpS best32.
sEmpTotal best32.
sEmpSpv best32.
sHirA best32.
sHirN best32.
sHirR best32.
sSep best32.
sHirAEnd best32.
sSepBeg best32.
sHirAEndRepl best32.
sHirAEndR best32.
sSepBegR best32.
sHirAEndReplR best32.
sHirAS best32.
sHirNS best32.
sSepS best32.
sSepSnx best32.
sTurnOvrS best32.
sFrmJbGn best32.
sFrmJbLs best32.
sFrmJbC best32.
sFrmJbGnS best32.
sFrmJbLsS best32.
sFrmJbCS best32.
sEarnS best32.
sEarnBeg best32.
sEarnHirAS best32.
sEarnHirNS best32.
sEarnSepS best32.
sPayroll best32.
			;
			label
periodicity='Periodicity of report'
seasonadj='Seasonal Adjustment Indicator'
geo_level='Group: Geographic level of aggregation'
geography='Group: Geography code'
ind_level='Group: Industry level of aggregation'
industry='Group: Industry code'
ownercode='Group: Ownership group'
sex='Group: Gender'
agegrp='Group: Age group'
race='Group: race'
ethnicity='Group: ethnicity'
education='Group: education'
firmage='Group: Firm Age group'
firmsize='Group: Firm Size group'
year='Time: Year'
quarter='Time: Quarter'
Emp='Employment: Counts'
EmpEnd='Employment end-of-quarter: Counts'
EmpS='Employment stable jobs: Counts'
EmpTotal='Employment reference quarter: Counts'
EmpSpv='Employment stable jobs - previous quarter: Counts'
HirA='Hires All: Counts'
HirN='Hires New: Counts'
HirR='Hires Recalls: Counts'
Sep='Separations: Counts'
HirAEnd='End-of-quarter hires'
SepBeg='Beginning-of-quarter separations'
HirAEndRepl='Replacement hires'
HirAEndR='End-of-quarter hiring rate'
SepBegR='Beginning-of-quarter separation rate'
HirAEndReplR='Replacement hiring rate'
HirAS='Hires All stable jobs: Counts'
HirNS='Hires New stable jobs: Counts'
SepS='Separations stable jobs: Counts'
SepSnx='Separations stable jobs - next quarter: Counts'
TurnOvrS='Turnover stable jobs: Ratio'
FrmJbGn='Firm Job Gains: Counts'
FrmJbLs='Firm Job Loss: Counts'
FrmJbC='Firm jobs change: Net Change'
FrmJbGnS='Firm Gain stable jobs: Counts'
FrmJbLsS='Firm Loss stable jobs: Counts'
FrmJbCS='Firm stable jobs change: Net Change'
EarnS='Employees stable jobs: Average monthly earnings'
EarnBeg='Employees beginning-of-quarter : Average monthly earnings'
EarnHirAS='Hires All stable jobs: Average monthly earnings'
EarnHirNS='Hires New stable jobs: Average monthly earnings'
EarnSepS='Separations stable jobs: Average monthly earnings'
Payroll='Total quarterly payroll: Sum'
sEmp='Status: Employment: Counts'
sEmpEnd='Status: Employment end-of-quarter: Counts'
sEmpS='Status: Employment stable jobs: Counts'
sEmpTotal='Status: Employment reference quarter: Counts'
sEmpSpv='Status: Employment stable jobs - previous quarter: Counts'
sHirA='Status: Hires All: Counts'
sHirN='Status: Hires New: Counts'
sHirR='Status: Hires Recalls: Counts'
sSep='Status: Separations: Counts'
sHirAEnd='Status: End-of-quarter hires'
sSepBeg='Status: Beginning-of-quarter separations'
sHirAEndRepl='Status: Replacement hires'
sHirAEndR='Status: End-of-quarter hiring rate'
sSepBegR='Status: Beginning-of-quarter separation rate'
sHirAEndReplR='Status: Replacement hiring rate'
sHirAS='Status: Hires All stable jobs: Counts'
sHirNS='Status: Hires New stable jobs: Counts'
sSepS='Status: Separations stable jobs: Counts'
sSepSnx='Status: Separations stable jobs - next quarter: Counts'
sTurnOvrS='Status: Turnover stable jobs: Ratio'
sFrmJbGn='Status: Firm Job Gains: Counts'
sFrmJbLs='Status: Firm Job Loss: Counts'
sFrmJbC='Status: Firm jobs change: Net Change'
sFrmJbGnS='Status: Firm Gain stable jobs: Counts'
sFrmJbLsS='Status: Firm Loss stable jobs: Counts'
sFrmJbCS='Status: Firm stable jobs change: Net Change'
sEarnS='Status: Employees stable jobs: Average monthly earnings'
sEarnBeg='Status: Employees beginning-of-quarter : Average monthly earnings'
sEarnHirAS='Status: Hires All stable jobs: Average monthly earnings'
sEarnHirNS='Status: Hires New stable jobs: Average monthly earnings'
sEarnSepS='Status: Separations stable jobs: Average monthly earnings'
sPayroll='Status: Total quarterly payroll: Sum'
			;
			input 
periodicity
seasonadj
geo_level
geography
ind_level
industry
ownercode
sex
agegrp
race
ethnicity
education
firmage
firmsize
year
quarter
Emp
EmpEnd
EmpS
EmpTotal
EmpSpv
HirA
HirN
HirR
Sep
HirAEnd
SepBeg
HirAEndRepl
HirAEndR
SepBegR
HirAEndReplR
HirAS
HirNS
SepS
SepSnx
TurnOvrS
FrmJbGn
FrmJbLs
FrmJbC
FrmJbGnS
FrmJbLsS
FrmJbCS
EarnS
EarnBeg
EarnHirAS
EarnHirNS
EarnSepS
Payroll
sEmp
sEmpEnd
sEmpS
sEmpTotal
sEmpSpv
sHirA
sHirN
sHirR
sSep
sHirAEnd
sSepBeg
sHirAEndRepl
sHirAEndR
sSepBegR
sHirAEndReplR
sHirAS
sHirNS
sSepS
sSepSnx
sTurnOvrS
sFrmJbGn
sFrmJbLs
sFrmJbC
sFrmJbGnS
sFrmJbLsS
sFrmJbCS
sEarnS
sEarnBeg
sEarnHirAS
sEarnHirNS
sEarnSepS
sPayroll
			;
/*
		** include data labels for all class variables **;
		** this section has been commented out to minimize the size of output files  **;
length periodicityfm $20;
periodicityfm=trim(put(periodicity,$periodi.));
length seasonadjfm $30;
seasonadjfm=trim(put(seasonadj,$seasona.));
length geo_levelfm $40;
geo_levelfm=trim(put(geo_level,$geo_lev.));
length geographyfm $75;
geographyfm=trim(put(geography,$geograp.));
length ind_levelfm $40;
ind_levelfm=trim(put(ind_level,$ind_lev.));
length industryfm $120;
industryfm=trim(put(industry,$industr.));
length ownercodefm $20;
ownercodefm=trim(put(ownercode,$ownerco.));
length sexfm $20;
sexfm=trim(put(sex,$sex.));
length agegrpfm $16;
agegrpfm=trim(put(agegrp,$agegrp.));
length racefm $50;
racefm=trim(put(race,$race.));
length ethnicityfm $25;
ethnicityfm=trim(put(ethnicity,$ethnici.));
length educationfm $35;
educationfm=trim(put(education,$educati.));
length firmagefm $20;
firmagefm=trim(put(firmage,$firmage.));
length firmsizefm $20;
firmsizefm=trim(put(firmsize,$firmsiz.));
*/
			output;
		end;
	end;
datalines;
qwi_ak_rh_f_gc_n3_op_u.csv.gz
qwi_ak_rh_f_gc_n3_oslp_u.csv.gz
qwi_ak_rh_f_gc_n4_op_u.csv.gz
qwi_ak_rh_f_gc_n4_oslp_u.csv.gz
qwi_ak_rh_f_gc_ns_op_u.csv.gz
qwi_ak_rh_f_gc_ns_oslp_u.csv.gz
qwi_ak_rh_f_gm_n3_op_u.csv.gz
qwi_ak_rh_f_gm_n3_oslp_u.csv.gz
qwi_ak_rh_f_gm_n4_op_u.csv.gz
qwi_ak_rh_f_gm_n4_oslp_u.csv.gz
qwi_ak_rh_f_gm_ns_op_u.csv.gz
qwi_ak_rh_f_gm_ns_oslp_u.csv.gz
qwi_ak_rh_f_gs_n3_op_u.csv.gz
qwi_ak_rh_f_gs_n3_oslp_u.csv.gz
qwi_ak_rh_f_gs_n4_op_u.csv.gz
qwi_ak_rh_f_gs_n4_oslp_u.csv.gz
qwi_ak_rh_f_gs_ns_op_u.csv.gz
qwi_ak_rh_f_gs_ns_oslp_u.csv.gz
qwi_ak_rh_f_gw_n3_op_u.csv.gz
qwi_ak_rh_f_gw_n3_oslp_u.csv.gz
qwi_ak_rh_f_gw_n4_op_u.csv.gz
qwi_ak_rh_f_gw_n4_oslp_u.csv.gz
qwi_ak_rh_f_gw_ns_op_u.csv.gz
qwi_ak_rh_f_gw_ns_oslp_u.csv.gz
qwi_ak_rh_fa_gc_ns_op_u.csv.gz
qwi_ak_rh_fa_gm_ns_op_u.csv.gz
qwi_ak_rh_fa_gs_n3_op_u.csv.gz
qwi_ak_rh_fa_gs_n4_op_u.csv.gz
qwi_ak_rh_fa_gs_ns_op_u.csv.gz
qwi_ak_rh_fa_gw_ns_op_u.csv.gz
qwi_ak_rh_fs_gc_ns_op_u.csv.gz
qwi_ak_rh_fs_gm_ns_op_u.csv.gz
qwi_ak_rh_fs_gs_n3_op_u.csv.gz
qwi_ak_rh_fs_gs_n4_op_u.csv.gz
qwi_ak_rh_fs_gs_ns_op_u.csv.gz
qwi_ak_rh_fs_gw_ns_op_u.csv.gz
qwi_ak_sa_f_gc_n3_op_u.csv.gz
qwi_ak_sa_f_gc_n3_oslp_u.csv.gz
qwi_ak_sa_f_gc_n4_op_u.csv.gz
qwi_ak_sa_f_gc_n4_oslp_u.csv.gz
qwi_ak_sa_f_gc_ns_op_u.csv.gz
qwi_ak_sa_f_gc_ns_oslp_u.csv.gz
qwi_ak_sa_f_gm_n3_op_u.csv.gz
qwi_ak_sa_f_gm_n3_oslp_u.csv.gz
qwi_ak_sa_f_gm_n4_op_u.csv.gz
qwi_ak_sa_f_gm_n4_oslp_u.csv.gz
qwi_ak_sa_f_gm_ns_op_u.csv.gz
qwi_ak_sa_f_gm_ns_oslp_u.csv.gz
qwi_ak_sa_f_gs_n3_op_u.csv.gz
qwi_ak_sa_f_gs_n3_oslp_u.csv.gz
qwi_ak_sa_f_gs_n4_op_u.csv.gz
qwi_ak_sa_f_gs_n4_oslp_u.csv.gz
qwi_ak_sa_f_gs_ns_op_u.csv.gz
qwi_ak_sa_f_gs_ns_oslp_u.csv.gz
qwi_ak_sa_f_gw_n3_op_u.csv.gz
qwi_ak_sa_f_gw_n3_oslp_u.csv.gz
qwi_ak_sa_f_gw_n4_op_u.csv.gz
qwi_ak_sa_f_gw_n4_oslp_u.csv.gz
qwi_ak_sa_f_gw_ns_op_u.csv.gz
qwi_ak_sa_f_gw_ns_oslp_u.csv.gz
qwi_ak_sa_fa_gc_ns_op_u.csv.gz
qwi_ak_sa_fa_gm_ns_op_u.csv.gz
qwi_ak_sa_fa_gs_n3_op_u.csv.gz
qwi_ak_sa_fa_gs_n4_op_u.csv.gz
qwi_ak_sa_fa_gs_ns_op_u.csv.gz
qwi_ak_sa_fa_gw_ns_op_u.csv.gz
qwi_ak_sa_fs_gc_ns_op_u.csv.gz
qwi_ak_sa_fs_gm_ns_op_u.csv.gz
qwi_ak_sa_fs_gs_n3_op_u.csv.gz
qwi_ak_sa_fs_gs_n4_op_u.csv.gz
qwi_ak_sa_fs_gs_ns_op_u.csv.gz
qwi_ak_sa_fs_gw_ns_op_u.csv.gz
qwi_ak_se_f_gc_n3_op_u.csv.gz
qwi_ak_se_f_gc_n3_oslp_u.csv.gz
qwi_ak_se_f_gc_n4_op_u.csv.gz
qwi_ak_se_f_gc_n4_oslp_u.csv.gz
qwi_ak_se_f_gc_ns_op_u.csv.gz
qwi_ak_se_f_gc_ns_oslp_u.csv.gz
qwi_ak_se_f_gm_n3_op_u.csv.gz
qwi_ak_se_f_gm_n3_oslp_u.csv.gz
qwi_ak_se_f_gm_n4_op_u.csv.gz
qwi_ak_se_f_gm_n4_oslp_u.csv.gz
qwi_ak_se_f_gm_ns_op_u.csv.gz
qwi_ak_se_f_gm_ns_oslp_u.csv.gz
qwi_ak_se_f_gs_n3_op_u.csv.gz
qwi_ak_se_f_gs_n3_oslp_u.csv.gz
qwi_ak_se_f_gs_n4_op_u.csv.gz
qwi_ak_se_f_gs_n4_oslp_u.csv.gz
qwi_ak_se_f_gs_ns_op_u.csv.gz
qwi_ak_se_f_gs_ns_oslp_u.csv.gz
qwi_ak_se_f_gw_n3_op_u.csv.gz
qwi_ak_se_f_gw_n3_oslp_u.csv.gz
qwi_ak_se_f_gw_n4_op_u.csv.gz
qwi_ak_se_f_gw_n4_oslp_u.csv.gz
qwi_ak_se_f_gw_ns_op_u.csv.gz
qwi_ak_se_f_gw_ns_oslp_u.csv.gz
qwi_ak_se_fa_gc_ns_op_u.csv.gz
qwi_ak_se_fa_gm_ns_op_u.csv.gz
qwi_ak_se_fa_gs_n3_op_u.csv.gz
qwi_ak_se_fa_gs_n4_op_u.csv.gz
qwi_ak_se_fa_gs_ns_op_u.csv.gz
qwi_ak_se_fa_gw_ns_op_u.csv.gz
qwi_ak_se_fs_gc_ns_op_u.csv.gz
qwi_ak_se_fs_gm_ns_op_u.csv.gz
qwi_ak_se_fs_gs_n3_op_u.csv.gz
qwi_ak_se_fs_gs_n4_op_u.csv.gz
qwi_ak_se_fs_gs_ns_op_u.csv.gz
qwi_ak_se_fs_gw_ns_op_u.csv.gz
;
run;

