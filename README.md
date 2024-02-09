## **How is coronary heart disease associated with health behaviors and use of prevention services in North Carolina?**

### Cynthia Fisher

In this project I aimed to determine whether health behaviors and use of prevention services associated with coronary heart disease prevalence on acensus tract level in North Carolina.


To explore these connections, I used the PLACES Data, published by the Centers for Disease Control and Prevention. This data set provides estimates for 29 measures of health-related data, all at the census-tract level. The measures included health outcomes, use of preventative services, health risk behaviors, and health status. For this project, I focused on use of preventative services and health risk behaviors. The data was gathered from Behavioral Risk Factor Surveillance System (BRFSS), the 2010 census, and American Community Survey. It is available [here](https://chronicdata.cdc.gov/500-Cities-Places/PLACES-Local-Data-for-Better-Health-Census-Tract-D/cwsq-ngmh/about_data). 

## Getting started

First, open your perferred terminal and clone this repository by running this command.

```
git clone https://github.com/castriab/CHD

cd CHD/
```

This repository can be built using Docker. Run this command in your terminal to create a docker container.

``` 
docker build . -t chd 
``` 

Then to launch the docker container run this command

```
docker run -v $(pwd):/home/rstudio/work -e PASSWORD=yourpassword --rm -p 8787:8787 rocker/verse
```

If you are running Windows Powershell you may need to use this code instead

```
docker run -v ${PWD}:/home/rstudio/workk -e PASSWORD=yourpassword --rm -p 8787:8787 rocker/verse
```

Now you are able to log in to a locally hosted RStudio server. Open your web browser and navigate to http://localhost:8787 . Then, log on with the username `rstudio` and password `yourpassword`.

## Project Organization
The best way to understand what this project does is to examine the Makefile.

A Makefile is a textual description of the relationships between artifacts (like data, figures, source files, etc.). In particular, it documents for each artifact of interest in the project: 
  - What is needed to construct that artifact 
  - How to construct it
  
A Makefile is more than documentation. Using the tool make (included in the Docker container), the Makefile allows for the automatic reproduction of an artifact (and all the artifacts which it depends on) by simply issuing the command to make it.

Consider this snippet from the Makefile included in this project:

```
	# Make figures for report
figures/CHD_distribution.png: .created-dirs source_data/places_nomissing.csv code/CHD_distribution.R
	Rscript code/CHD_distribution.R
```
The lines with `#` are comments which describe the target. 
Here we describe an artifact (`figures/CHD_distribution.png`), its dependencies (`.created-dirs`, `source_data/places_nomissing.csv`, `code/CHD_distribution.R`) and how to build it Rscript `code/CHD_distribution.R`. If we invoke Make like so:

```
make figures/CHD_distribution.png
```

Make will construct this artifact for us. If a dependency does not exist for some reason it will also construct that artifact on the way. 

## Building the final report

In order to generate the final report, use the following command. Ensure that you are in the `work` directory while running this command.

```
make Report.html
```



