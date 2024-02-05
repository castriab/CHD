.PHONY: clean

clean:
	rm -rf figures
	rm -rf derived_data
	rm -rf .created-dirs

.created-dirs:
	mkdir -p figures
	mkdir -p derived_data
	touch .created-dirs
	
# Data cleaning 
derived_data/cleaned_data.csv: .created-dirs code/data_cleaning.R source_data/CDC_Drug_Overdose_Deaths.csv source_data/SSP_Data.csv
	Rscript code/data_cleaning.R

# CSV table for regression
derived_data/coefficients_table.csv: .created-dirs code/regression.R source_data/CDC_Drug_Overdose_Deaths.csv source_data/SSP_Data.csv
	Rscript code/regression.R