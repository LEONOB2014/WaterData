# Hydrology Data Processing and Analysis - MATLAB

This is a suite for processing and analyzing a broad range of data related to my study of watershed hydrology at UC Berkeley. Because the software needs were driven by exploratory scientific questions, the development was ad hoc and not intended for use by others. Furthermore, to do it over again, I would use Python/R rather than MATLAB. That said, there are some interesting coding challenges addressed within, so I've put some effort into organzing and documenting the code. 

## /PreProcessing
Run once or as new data sources are added. All necessary functions executed from RUN_CATCHMENT_PROCESSING_MASTER.m

* Pre-process raw data from various providers - simple to add new types and sources
* Setup directory structure for processed data and analysis outputs
* Download and process geospatial features such as watershed boundaries
* Pre-process weighted averages of geospatial grids within geographic boundaries - key to quick processing
* Convert geospatial to timeseries: calculate weighted mean (or other metrics) within geographic bounds
* Save data in common format

## /WaterBalanceCalcs

