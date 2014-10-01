## Hydrology Data Processing and Analysis - MATLAB

This is a suite for processing and analyzing a broad range of data related to my study of watershed hydrology at UC Berkeley. Because the software needs were driven by exploratory scientific questions, the development was ad hoc and not done with sharing in mind. Furthermore, to do it over again, I would use Python/R rather than MATLAB. That said, there are some interesting coding challenges addressed within, so I've put some effort into organizing and documenting the code, and I'm glad to help anyone get up and running. 

### /PreProcessing
Run once or as new data sources are added. All necessary functions executed from RUN_CATCHMENT_PROCESSING_MASTER.m

* Pre-process raw data from various providers - simple to add new types and sources
* Setup directory structure for processed data and analysis outputs
* Download and process geospatial features such as watershed boundaries
* Pre-process weighted averages of geospatial grids within geographic boundaries - key to quick processing
* Convert geospatial to timeseries: calculate weighted mean (or other metrics) within geographic bounds
* Save data in common format

### /WaterBalanceCalcs
Calculate annual and monthly water balances for hydologic analysis.

### /WB_AnalysisTools
A slew of functions to address specific hydrologic questions. Examples
* BASEFLOW_FILTER2(Q,cys,a) filters baseflow U from daily mean streamflow Q using the one parameter recursive filter described in Voepel et al. 2011
* CALC_HORTON_INDEX1(Pmonthly,Rdaily) calculates the yearly Horton index from precip P and runoff R.
* wswb_annual_P_gage_find(st) finds all precipitation gages located within a given boundary
* WSWB_CALC_MEAN_RECESSION(Rb,wyday1) estimates the baseflow recession slope
* WSWB_CALC_NONNESTED_FLUX(Xout,Aout,Xin,Ain) calculates the weighted flux of variable X for the non-nested area of an outer watershed with area Aout by subtracting the flux of the inner nested watershed with area Ain.
* WSWB_NESTED_CATCHMENT_CHECK(dir_master,flist) finds nested watersheds
* WSWB_NESTED_SCENES(st_master,ID,ids,var_type) determines intervals and IDs for calculations involving nested watersheds 'ids' that are nested in watershed 'ID'.
* WSWB_PERENNIAL_STREAM_CHECK(ws_list, dir_master) checks the fraction of years that a stream goes dry
* WSWB_SEAS_CALC_WETSEAS(Pdaily,SeasThresh) calculates the first and last day of the wet season based on cumulative precipitation thresholds

### /Utilities
Utility functions for data parsing, conversions, import/export, etc. 

### /Modeling
Estimate parameters for various water balance models - SUPERSEDED BY BAYESIAN MCMC WITH PYTHON & R

### /WB_Uncertainty
Characterize posterior distributions from Python MCMC, i.e. fit classical distributions to posteriors. SciPy approaches for this were found to be unstable/unreliable. 

