.PHONY: clean

clean:
	rm -rf figures
	rm -rf derived_data
	rm -rf .created-dirs

.created-dirs:
	mkdir -p figures
	mkdir -p derived_data
	touch .created-dirs
	
	# Make figures for report
figures/CHD_distribution.png: .created-dirs source_data/places_nomissing.csv code/CHD_distribution.R
	Rscript code/CHD_distribution.R
	
figures/correlation_matrix.png: .created-dirs source_data/places_nomissing.csv code/correlation.R
	Rscript code/correlation.R
	
figures/nc_chd_prevalence_map.png: .created-dirs source_data/places_nomissing.csv code/map_chd_counties.R
	Rscript code/map_chd_counties.R
	
figures/nc_cholscreen_map.png: .created-dirs source_data/places_nomissing.csv code/map_chol_counties.R
	Rscript code/map_chol_counties.R

figures/nc_smoking_map.png: .created-dirs source_data/places_nomissing.csv code/map_smoking_counties.R
	Rscript code/map_smoking_counties.R
		
	
	
	
	
	
