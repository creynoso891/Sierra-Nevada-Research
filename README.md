# Microhabitat Preferences in Giant Sequoia Seedling
Researching the microhabitat preferences of Giant Sequoia seedlings. 

Giant sequoias (Sequoiadendron giganteum [Lindl.] Buchholz) are towering endemic trees that reside in small plots throughout the Sierra Nevada Mountains. They can live for more than 3200 years (Stephenson and Demetry, 1995), and are resilient to drought and excessive foliage.

## Table of Contents
* [Installation](#Installation)
* [About the Data](#About)
* [Project Motivation](#motivation)
* [File Description](#description)
* [Results and Insights](#Results)
* [Limitations and Further Questions](#Limitations)
* [Licensing, Authors, Acknowledgements](#licensing)

## Installation
To get started you will need a recent version of RStudio. Additionally, the packages used in the project can be downloaded running the following at the command line:
    
        install.packages(c("readxl", "jsonlite", "dplyr", "tidyr", "xlsx", "lubridate", "stringr", 
                             "ggplot2", "graphics", "kableExtra", "knitr"))
                            
## About the Data <a name="About"></a>
The data set used for the analysis is an aggregation of several data sets organized by subplot. 111 HOBO units were placed on plots of land throughout Yosemite National Park. These HOBO units measured the lux and temperature of the subplot every 30 minutes from 2016-08-26 to 2017-10-25. I created summary statistics for each of the plots and then joined this information with seedling count and soil moisture at various depths.

## Project Motivation <a name="motivation"></a>
In recent years we have seen a decline in the recruitment of Giant sequoias, with some sequoia plots not showing signs of any new life. In this research project we study the relationship between weather conditions, soil moisture, and isotope components in the soil to determine what microhabitat variables can best predict the presence of sequoia seedlings.

## File Description <a name="description"></a>
This project includes:
1. R file 
2. **[Microhabitat Preferences in Giant Sequoia Seedling.Rmd](https://github.com/creynoso891/Sierra-Nevada-Research/blob/main/Microhabitat%20Preferences%20in%20Giant%20Sequoia%20Seedling.Rmd):** R Markdown with the code to analyze, model, and vizualize CO2 monthly means data.
3. **Microhabitat Preferences in Giant Sequoia Seedling.pdf** PDF produced using the R Markdown above (for complete code please refer to the R Markdowm above) 


## Results and Insights <a name="Results"></a>

## Licensing, Authors, Acknowledgements <a name="licensing"></a>
