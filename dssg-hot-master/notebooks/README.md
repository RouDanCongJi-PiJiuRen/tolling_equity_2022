# Code review: DSSG-HOT-MASTER/notebooks

## cj
### Notebook Overview
- geo_travel_behavior.ipynb - looks at common attributes of census block groups and travel behavior  
- hov_with_tolls_exploration.ipynb - looks further into why some trips marked HOV have tolls  
- initial_analysis.ipynb - initial analysis of non-trip level data  
- joined_data_analysis.ipynb - analysis of trip data with initial census estimates; includes early maps  
- mcib_replication.ipynb - replication of the means-constrained integration brackets method for estimating means of bins of census groups  
- modal_vot.ipynb - analysis of HOV users  
- presentation_viz.ipynb - creating analysis for presentation  
- speed_vol_exploration.ipynb - exploration of relationships between speed, volume and travel time  
- survey_analysis.ipynb - analysis of WSDOT survey from 2017  
- travel_behavior.ipynb - looking into single users' predictibility and commuting patterns
-feel free to look more into this - this analysis mainly shows that most people traveling in the HOT lanes do not travel in regular patterns that are easy to identify. i think it'd be interesting to try and quantify how many of these users actually use the facility predictibly and are "regular commuters" (however you define that)  
- unusual_trips_and_fips.ipynb - exploring unusually high frequency trips and areas  
- wsdot_initial_analysis.ipynb - initial analysis of non-matched trip-level data
Folders  
- shiny_apps - holds R shiny apps to help visualize benefit distributions from Cory's notebooks  

## Shirley 
### Folders
- figs - folder containing saved out figures from notebooks
- sql - folder containing sql code
Code
- acs_info_maps.ipynb - makes maps of census block group characteristics from census (American Community Survey) data
- customer_survey_analysis.ipynb - some simple analyses of 2018 WSDOT HOT lane customer survey data
- edit_shapefiles.ipynb - manipulates shapefiles to be able to use them in Tableau, can mostly ignore this
- get_functioning_loops.ipynb - grabs the closest functioning loop detectors to toll entry/exit mileposts
- price_timeseries_analysis.ipynb - looks at toll prices over diff times of day, etc.
- spatial_analysis_interactive.ipynb - creates interactive visualization of geographic variables using altair (cool interactive python package)
- spatial_analysis_load.ipynb - loads trips database, filters trips (for commercial users, etc.); loads shapefiles for map visualizations; called by spatial_analysis_interactive.ipynb, spatial_analysis_plot_maps.ipynb, spatial_analysis_plot_relationships.ipynb
- spatial_analysis_plot_maps.ipynb - creates maps of many diff variables by block group
- spatial_analysis_plot_relationships.ipynb - aggregates many variables by block group and looks at relnship btwn these variables on the block group level; saves out csv with aggregated block group info to further explore interactively in tableau
- travel_time_analysis_load_and_define_fxns.ipynb - loads travel time data; called by travel_time_analysis_plots.ipynb
- travel_time_analysis_plots.ipynb - plots travel time data by weekday or month, etc.
- exploration_shirley.sql - playing around/exploring characteristics of the trips data in sql
- joinall_shirley.sql - practicing joining all the trips files, can mostly ignore this

## Kiana 
### Folders
- figs - folder containing saved out figures from notebooks
- sql - folder containing sql code
### Code
- clustering.ipynb - Making different clusters based on different travel pattern and characteristics
- Hov_PSRC.ipynb - Analyzing HOV and SOV users in Puget sound regional council trip survey
- crash_analysis.ipynb - Making some preliminary analysis on crash data along I-405
- Suit_index_city.ipynb - Using ecological regression for developing suits index at city level
- suits_index.ipynb - Previous methodology for developing suits index at county level
- testdb.ipynb - Matching travel time savings and travel time reliability to the trips
- Travel_time.ipynb - Quality check and analyzing the travel time data

## Cory
### Important notebooks
- ecological_regression does most of the usage patterns by mode, and income.
- route_distributions does most of the usage patterns by route.
- VOT_VOR_estimation estimates the value of time (VOT) and reliability (VOR) for facility users.
- aggregate_benefits analyzes the distribution of benefits and costs by mode, income, race, frequency, and time of day.
- equity_maps plots usage and benefit patterns on maps.
- equity_graphs makes equity plots for reports or presentations.
- policy examines several potential policy interventions.
Data preparation notebooks
- toll_time creates a toll file.
- tracflow creates a speed-volume file.


