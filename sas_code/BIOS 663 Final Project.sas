
LIBNAME bb3 '/home/u49494474/BIOS 663/Final Project'; /*Assigns a libref that points to my data folder*/

DATA places;
	set bb3.nc_places_short;
	int = 1;
	log_chd = log(chd);
	log_bpmed = log(bpmed);
	bpmed_cub = bpmed ** 3;
	sqrt_chd = sqrt(chd);
run;

/*-------------------------------------------------------------------------------------------------------*/

title "Health Risk Behaviors and Prevention";

* Full New Model;
symbol value = circle;
PROC REG data=places plots;
	model chd = binge csmoking lpa sleep 
				cervical cholscreen access2 colon_screen 
				mammouse corem corew bpmed dental checkup / vif ;
	plot residual.* predicted.;
	plot residual.*nqq.;
run;

symbol value = circle;
PROC REG data=places plots;
	model sqrt_chd = binge csmoking lpa sleep 
				cervical cholscreen access2 colon_screen 
				mammouse corem corew bpmed_cub dental checkup / vif;
	plot residual.*nqq.;
run;

symbol value = circle;
PROC REG data=places;
	model sqrt_chd = csmoking sleep 
				cervical  access2  
				mammouse corem bpmed_cub dental checkup / vif;
run;

/*Transform data?*/
proc transreg data=BoxCox details
	plots=(residuals transformation);
	model boxcox(y)=identity(x);
	output out=boxcoxtrans_data;
run;

proc reg data=boxcoxtrans_data;
model Ty=Tx;
run;

* Reduced New Model (removed LPA variable);
PROC REG data=places plots(only) = (CooksD(label) DFFits(label));
title "Health Risk Behaviors and Prevention";
	model sqrt_chd = binge csmoking  sleep 
				cervical cholscreen access2 colon_screen 
				mammouse corem corew bpmed_cub dental checkup / vif;
	output out=RegOut dffits=DFFits cookd=CooksD;
run;

/*-------------------------------------------------------------------------------------------------------*/
/*backward selection*/
proc reg data=places outest=est;
	model sqrt_chd = binge csmoking  sleep 
				cervical cholscreen access2 colon_screen 
				mammouse corem corew bpmed_cub dental checkup/
		slstay=0.05 selection=backward
		ss2 sse aic;
	output out=out1 p=p r=r;
run; quit;

/* Tolerance and VIF */
PROC REG data=places;
	model sqrt_chd =  csmoking  sleep 
				cervical access2  
				mammouse corem  bpmed_cub dental checkup / vif;
	plot residual.* predicted.;
	plot residual.*nqq.;
run;

/**/


/************************************************************************************/
/*********************  	Eigenvalues and Condition Indices  	*********************/
/************************************************************************************/

/* Scaled SSCP */
proc princomp data=log_places noint outstat=scaled_sscp;
	var Tchd csmoking sleep lpa
			cervical cholscreen access2 colon_screen
			mammouse corew bpmed dental checkup  ;
run;

/* Correlation matrix */
proc princomp data=log_places outstat=corr_matrix;
	var Tchd csmoking sleep lpa
			cervical cholscreen access2 colon_screen
			mammouse  corew bpmed dental checkup  ;
run;

proc transpose data=scaled_sscp (where=(_TYPE_="EIGENVAL")) out=sscp_eigen;
	id _type_;
	var Tchd csmoking sleep lpa
			cervical cholscreen access2 colon_screen
			mammouse  corew bpmed dental checkup   ;
run;

proc transpose data=corr_matrix (where=(_TYPE_="EIGENVAL")) out=corr_eigen;
	id _type_;
	var Tchd csmoking sleep lpa
			cervical cholscreen access2 colon_screen
			mammouse  corew bpmed dental checkup   ;
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

/*-------------------------------------------------------------------------------------------------------*/


/************************************************************/
/*********************  	BoxCox  	*********************/
/************************************************************/

proc transreg data=places ss2 details;
title2 Defaults;
	model boxcox(chd) =
	identity(binge csmoking sleep lpa cervical cholscreen access2 colon_screen
			mammouse corem corew bpmed dental checkup);
	output out=places_boxcox;
run;

proc reg data=places_boxcox;
	model Tchd=binge csmoking sleep lpa cervical cholscreen access2 colon_screen
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

/*backwards*/

proc reg data=places_boxcox outest=est;
	model Tchd = binge csmoking lpa sleep 
				cervical cholscreen access2 colon_screen 
				mammouse corem corew bpmed dental checkup/
		slstay=0.05 selection=backward
		ss2 sse aic;
	output out=out1 p=p r=r;
run; quit;


/*VIF*/

PROC REG data=log_places;* plots=none;
title "Health Risk Behaviors and Prevention";
*	model chd = binge csmoking sleep
				cervical cholscreen access2 colon_screen
				mammouse corem corew bpmed dental checkup / vif;
	model Tchd = csmoking sleep lpa
			cervical cholscreen access2 colon_screen
			mammouse corem corew bpmed dental checkup / vif ;
*	output out=log_places cookd=cd;
run;


PROC REG data=log_places;* plots=none;
title "Health Risk Behaviors and Prevention";
*	model chd = binge csmoking sleep
				cervical cholscreen access2 colon_screen
				mammouse corem corew bpmed dental checkup / vif;
	model Tchd = csmoking sleep
			cervical cholscreen access2 colon_screen
			mammouse corem corew bpmed dental checkup / vif ;
*	output out=log_places cookd=cd;
run;










