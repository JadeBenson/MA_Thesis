# MA_Thesis

This repo contains my 2022 Master's Thesis for Computational Social Science at the University of Chicago. 

In this thesis, I aim to investigate the epidemiology of falls that caused hospitalizations among adults 65 years and older in the United States, its association with meteorological indicators, the influence of demographic and socioeconomic variables, and how these relationships vary by modeling approach. I combine six years (July 2009 – July 2015) of monthly Medicare falls-related claims with meteorological data from the National Oceanic and Atmospheric Administration’s (NOAA) National Weather Service (NWS) and county sociodemographic characteristics from the 5-year estimates of the 2010 – 2014 American Community Survey (ACS) to investigate multiple research questions. These include: 1) What is the effect of weather on monthly county fall rates among adults aged 65 years and older? 2) What is the effect of county demographic variables on monthly county fall rates? 3) What is the effect of socioeconomic characteristics on monthly county fall rates? 4) What is the importance of all these variables on monthly county fall rates when placed in competitive models? Do these associations vary by region of the country? 5) How do different modeling approaches affect these relationships and their spatial patterns? 
 

This repo is organized as followed: 

Data folder: raw and processed data from Medicare (falls), National Weather Service (meteorological variables), and the 2010 - 2014 American Community Survey (demographic and economic variables). 

Preparation folder: This folder includes scripts used to collect and pre-process the raw data sources. The raw falls data processing occured in the Falls_processing.ipynb jupyter notebook (Python). The raw weather variable scraping and preparation with the meteostat library occured in the weather_processing_daily.ipynb jupyter notebook (Python). The ACS county-level demographic and socioeconomic variables were collected from and prepared in the ACS_thesis.R R script. 

Analysis folder: This folder includes scripts used to analyze the thesis data. Data_processing.ipynb is the jupyter notebook that merges all three data sources together, prepares/cleans it for further analysis, and creates some exploratory/descriptive visualizations. The data_analysis.ipynb includes all the descriptive statistics and random forests for national and regional models used in the thesis. The Thesis_analysis.Rmd includes the mixed-effects Poisson regression models. 
