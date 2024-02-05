%LET job=places_analysis;
%LET outdir=/home/u62053875/BIOS663;

DATA places;
	set bb3.nc_places_short; *For shorter label names;
	int = 1;
run;

/*---------------------------------------- 	Full Model 	-------------------------------------------*/

/*PDF output of different models*/
*ODS PDF FILE="&outdir/Output/&job..PDF" STYLE=JOURNAL;

* Full New Model;
PROC REG data=places plots=none;
title "Health Risk Behaviors and Prevention";
	model chd = binge csmoking lpa sleep
				cervical cholscreen access2 colon_screen
				mammouse corem corew bpmed dental checkup / vif;
run;
* Reduced New Model;
PROC REG data=places;* plots=none;
title "Health Risk Behaviors and Prevention";
	model chd = binge csmoking sleep
				cervical cholscreen access2 colon_screen
				mammouse corem corew bpmed dental checkup / vif;
	output out=reduced cookd=cd;
run;


*ODS PDF CLOSE;



/*--------------------------------- 	Selecting Reduced Model 	-----------------------------------*/

/* Backward Stepwise selection */
proc reg data=my_reduced outest=est;
	model chd = binge csmoking lpa sleep
				cervical cholscreen access2 colon_screen
				mammouse corem corew bpmed dental checkup/
		slstay=0.05 selection=backward
		ss2 sse aic tol vif;
	output out=out1 p=p r=r;
run; quit;

*NO OBSERVATIONS REMOVED;


/************************************************************************************/
/*********************  	Eigenvalues and Condition Indices  	*********************/ * NEW Reduced Model ;
/************************************************************************************/
* Remove: BPMED ARTHRITIS COLON_SCREEN BINGE DENTAL ;

/* Scaled SSCP */
proc princomp data=places noint outstat=scaled_sscp;
	var int chd binge csmoking sleep
				cervical cholscreen access2 colon_screen
				mammouse corem corew bpmed dental checkup ;
run;

/* Correlation matrix */
proc princomp data=places outstat=corr_matrix;
	var chd binge csmoking sleep
				cervical cholscreen access2 colon_screen
				mammouse corem corew bpmed dental checkup ;
run;

proc transpose data=scaled_sscp (where=(_TYPE_="EIGENVAL")) out=sscp_eigen;
	id _type_;
	var chd binge csmoking sleep
				cervical cholscreen access2 colon_screen
				mammouse corem corew bpmed dental checkup ;
run;

proc transpose data=corr_matrix (where=(_TYPE_="EIGENVAL")) out=corr_eigen;
	id _type_;
	var chd binge csmoking sleep
				cervical cholscreen access2 colon_screen
				mammouse corem corew bpmed dental checkup ;
run;

DATA sscp_cond_index;
	set sscp_eigen;
	retain lambda1 matrix_type;
	if _n_=1 then do; lambda1=eigenval; matrix_type="Scaled SSCP";
		_label_ = 'INT'; end;
	condition_index = sqrt(lambda1/eigenval);
	label condition_index="Condition Index"
		eigenval="Eigenvalue" matrix_type="Matrix Type";
run;

DATA corrmx_cond_index;
	set corr_eigen;
	retain lambda1 matrix_type;
	if _n_=1 then do; lambda1=eigenval; matrix_type="Correlation"; end;
	condition_index = sqrt(lambda1/eigenval);
	label condition_index="Condition Index"
		eigenval="Eigenvalue" matrix_type="Matrix Type";
run;

title "Scaled SSCP Condition Index";
PROC PRINT data=sscp_cond_index (drop=lambda1) label;
run;

title "Correlation Matrix Condition Index";
PROC PRINT data=corrmx_cond_index (drop=lambda1) label;
run;

data cond_index;
	set sscp_cond_index corrmx_cond_index;
run;

ODS PDF FILE="&outdir/Output/cond_index_red.PDF" STYLE=JOURNAL;
/************  	Condition Indices Report  	************/
TITLE "Eigenvalues and Condition Indices";
PROC REPORT data=cond_index NOWD;
	columns matrix_type _label_ eigenval condition_index;
	define matrix_type / order descending;
	define matrix_type / group;
	define _label_ / display "Covariate" LEFT;
	define eigenval / display RIGHT;
	define condition_index / display RIGHT;
run;
ODS PDF CLOSE;
/*-------------------------------------------------------------------------------------------------------*/



/************************************************************/
/*********************  	BoxCox  	*********************/
/************************************************************/

proc transreg data=places ss2 details;
title2 Defaults;
	model boxcox(chd) =
	identity(binge csmoking sleep cervical cholscreen access2 colon_screen
			mammouse corem corew bpmed dental checkup);
	output out=places_boxcox;
run;

proc reg data=places_boxcox;
	model Tchd=binge csmoking sleep cervical cholscreen access2 colon_screen
			mammouse corem corew bpmed dental checkup / tol vif;
run;




PROC REG data=places_boxcox;* plots=none;
title "Health Risk Behaviors and Prevention";
*	model chd = binge csmoking sleep
				cervical cholscreen access2 colon_screen
				mammouse corem corew bpmed dental checkup / vif;
	model Tchd = binge csmoking sleep
			cervical cholscreen access2 colon_screen
			mammouse corem corew bpmed dental checkup / vif;
	output out=log_places cookd=cd;
run;


* After BoxCox/log transformation and deleting one observation;
PROC REG data=log_places;* plots=none;
title "Health Risk Behaviors and Prevention";
*	model chd = binge csmoking sleep
				cervical cholscreen access2 colon_screen
				mammouse corem corew bpmed dental checkup / vif;
	model Tchd = binge csmoking sleep
			cervical cholscreen access2 colon_screen
			mammouse corem corew bpmed dental checkup / vif;
*	output out=log_places cookd=cd;
run;

