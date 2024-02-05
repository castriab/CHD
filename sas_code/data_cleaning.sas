%LET job=places;
%LET outdir=/home/u62053875/BIOS663;

/****************************************************************/
/*********************  	Data Details  	*********************/
/****************************************************************/

PROC IMPORT DATAFILE="/home/u62053875/BIOS663/Data/PLACES_2022.csv" DBMS=csv
	OUT=BB3.places REPLACE;
	GUESSINGROWS=50;
RUN;

/*PDF output*/
ODS PDF FILE="&outdir/Output/&job..PDF" STYLE=JOURNAL;

ODS EXCLUDE EngineHost ;
PROC CONTENTS data=bb3.places;
run;

PROC SQL number;
	TITLE "Parameters/Covariates";
	TITLE2 "MeasureID = Variable Name,  Measure = Variable Label  in Final Data Set";
	SELECT DISTINCT Category, CategoryID, Measure, Short_Question_Text, MeasureID 
		FROM bb3.places;
	title2;
	
	TITLE "Data Types";
	SELECT DISTINCT Data_Value_Unit, Data_Value_Type, DataValueTypeID
		FROM bb3.places;
	
	TITLE "Number of Counties and Tracts";
	SELECT COUNT(DISTINCT CountyName) as Counties, COUNT(DISTINCT CountyFIPS) as FIPS, 
			COUNT(DISTINCT LocationName) as CensusTracts
		FROM bb3.places
		WHERE MeasureID="CHD";
QUIT;

title "Checking Data Types - only Crude prevalence (%)";
PROC MEANS data=ncplaces n nmiss min max mean;
	var data_value;
run;

ODS PDF CLOSE;

/******************************************************************/
/*********************** 	Data Cleaning 	***********************/
/******************************************************************/

proc sort data=bb3.places out=ncplaces;
	by countyname locationname;
run;

data var_label; set ncplaces; if _n_ < 31; if measureid ne "CHD"; run;

PROC TRANSPOSE data=ncplaces out=ncplaces_transp;
	by CountyName LocationID TotalPopulation;
	id MeasureID;
	var Data_Value;
run;

PROC SQL noprint;
	SELECT Measure into :lab separated by "~"
		FROM var_label;
	SELECT MeasureID into :vars separated by " "
		FROM var_label;
	SELECT MeasureID into :sqlvars separated by ", "
		FROM var_label;
QUIT;
%PUT Labels = &lab;
%PUT Variables = &vars;

option noSYMBOLGEN noMPRINT noMLOGIC;
%macro label;
%do i=1 %to %sysfunc(countw(&vars.));
	%let var = %scan(&vars., &i.);
	%let label=%qsysfunc(scan("&lab.", &i., "~"));
	
	&var = "&label"
%end;
%mend;


DATA final;
	set ncplaces_transp;
	label %label CHD = "Coronary heart disease among adults aged >=18 years";
run;

PROC SQL noprint;
	CREATE TABLE bb3.NC_Places as
	SELECT CountyName, LocationID, TotalPopulation, CHD, &sqlvars
		FROM final;
QUIT;

