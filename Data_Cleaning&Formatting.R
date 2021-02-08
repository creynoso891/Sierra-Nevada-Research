#Data Cleaning and Structuring----------------------------------------------------------
#Current excel data is not structured in a rectagular way, so R cannot work with it
#Goal: 
# 1. Create a csv with the data with proper format for each of the HOBO units.
# 2. Files will be titled with the unit number of each HOBO to facilitated mining.
# 3. Adding in the unit ID and plot name to all the files

# Setting up the working environment-------------------------------------------
rm(list = ls(all = TRUE))
setwd("~/Sequoia Lab")
library(readxl)
library(jsonlite)
library(tidyr)
library(xlsx)
library(dplyr)
library(lubridate)
library(stringr)

# Read in Data-----------------------------------------------------------------
#extract the HOBO unit names to name data frames
unit_names <- read_excel("2016_Data/Hobo data/IndividualHOBOreadouts_OG.xlsx", 
                         range = "A1:PZ1", col_names = FALSE)
#format unit names as a number vector
unit_names <- as.integer(as.vector(na.omit(t(unit_names))))


#read in the data for all the HOBO units
HOBO <- read_excel("./2016_Data/Hobo data/IndividualHOBOreadouts_OG.xlsx", 
                   sheet = "Individual HOBO Readouts", col_names = FALSE, skip = 2)
# Data Cleaning----------------------------------------------------------------
#remove column that contains observation count. Not necessary
HOBO <- HOBO[, -c(seq(from = 1, to = 441, by = 4))]
n <- ncol(HOBO)/3 #number of HOBO units 


#rename columns
# "TimeGMT" - time when the measurements were taken. In GMT time zone 
# "TempC" - Temperature in degrees Celcius 
#"ILux" - Intensity of Lux at the sight 
name <- rep(c("TimeGMT", "TempC","ILux"),n)
names(HOBO) <- name


#create list with all with dataframes for each HOBO Unit-----------------------
data <- vector("list",n)
names(data) <- unit_names
index <- seq(from = 1, to = 333, by = 3)

for(i in 1:n){
  data[[i]] <- HOBO[ , index[i]:(index[i]+2)]
}


#Formating time zone------------------------------------------------------------
for(i in 1:n){
  data[[i]]$TimeGMT <- as.POSIXct(data[[i]]$TimeGMT, tz = "GMT", 
                                   tryFormat = "%Y-%m-%d %H:%M:%OS")
}


#Create CSV File for each HOBO unit---------------------------------------------
multiple_csv <- function(data, filename){
  for(i in 1:length(data)){
    write.csv(data[[i]], 
              file = paste0("./2016_Data/Hobo data/Unit Data/", filename[i], ".csv"),
              row.names = FALSE)
    
  }
}

#creates excel file 
#multiple_csv(data, unit_names) 


#Monthly Statistics-------------------------------------------------------------
#calculate the monthly statistics for temperature and lux for each HOBO unit 

monthly_stats <- vector("list",n)
names(monthly_stats) <- unit_names

for(i in 1:n){
  month_set <- data[[i]] %>% group_by(year(TimeGMT), month(TimeGMT)) %>% 
    summarise_at(vars(TempC, ILux),
        funs(mean, median, min, max, sd, sum), na.rm = TRUE)
  monthly_stats[[i]] <-  month_set[, -c(8, 13)]
  
}
rm(month_set)
 

#Measurement Period Statstics---------------------------------------------------
#calculate the statistics for temperature and lux for each HOBO unit 
#statistics pertain to the entirety of the period of time the HOBO was on the plot of land

#create empty dataframe of the appropriate size
measurement_period_stats <- data.frame(matrix(nrow = n, ncol = 10), row.names = unit_names)
#name the rows according to the HOBO units
names(measurement_period_stats) <- names(monthly_stats[[1]])[-c(1,2)]
#create measurements and store them in the empty data frame 
for(i in 1:n){
  measurement_set <- data[[i]] %>% 
    summarise_at(c('TempC', 'ILux'),
         funs(mean, median, min, max, sd, sum), na.rm = TRUE)
  
  measurement_period_stats[i, ] <- measurement_set[, -c(6, 11)]
}
rm(measurement_set)


#Add Plot Information--------------------------------------------------------
#This sequence will tell us where the HOBO unit is located 
#format for this Plot numer is as follows: 
#ex. T01W3a - reads as HOBO unit in plot 1 three subplots away from the center of plot 1 in the western direction
# T## - plot where the HOBO unit is located. This is an aggregation of several subplots. Several HOBO unit can be located in a single plot
# W (possible: N,E,S,W)  - Direction from the center of the plot where subplot is located 
# W3 - This means that the plot is located three subplots away from the center of the plot in the western direction 

#box_file is a file that I had previously worked on. 
#HOBO units are in the same order so we can just extract column as is 
box_file <- read.csv("./2016_Data/Hobo data/measurement_period_stats_box.csv")

measurement_period_stats <- as.data.frame(cbind(
  Plot = box_file$Subplot, Rep = box_file$Rep, measurement_period_stats
))

measurement_period_stats <- measurement_period_stats %>% 
  unite(col = "PlotName", c(Plot,Rep), sep = "")
#There is five HOBO units that do not have plot information
#this means that we will no be able to pair them with their seedling information

#correctly format NAs
sum(is.na(measurement_period_stats$PlotName))
measurement_period_stats[measurement_period_stats == "NA"] <- NA
sum(is.na(measurement_period_stats$PlotName))#check 


#Add Seedling information to the dataframe -------------------------------------------------
#Seedling data will serve as the output information for analysis 

#load excel file with the data 
seedling <- read_excel("2016_Data/SeedlingPlots_RawDataCombined-160921.xlsx", 
                       sheet = "HOBO plots")
#formating between seedling dataframe and measurement_period_stats for the plots is not compatible
#in order to make compatible make the following changes:
# T03N1 -> T3N1
#' -> a 
 # ex. T01W1' -> T01W1a
# '' -> b
 # ex. T01W1'' -> T01W1b 

seedling$PlotName <- str_replace_all(seedling$PlotName,
                                     pattern = "T0", replacement = "T")

seedling$PlotName <- str_replace_all(seedling$PlotName, pattern = "''", replacement = "b")
seedling$PlotName <- str_replace_all(seedling$PlotName, pattern = "'", replacement = "a")

#Remove the columns that we don't need so the join returns simplified data set
seedling <- seedling[, c("PlotName" ,"# Seedlings", "short", "med", "long", "Duff Depth Avg. (mm)")]
#Remove empty rows
seedling <- seedling[-c(115,116),]
names(seedling)[2] <- "seedlings"

#fix mistake in seedling count
#11.2 -> 11
seedling$seedlings[which(seedling$seedlings == 11.2)] <- 11

#Join the data from Seedling and measurement_period_stats ------------------------------
#match measurement_period_stats$Plot with seedling$PlotName to bring over data from columns:
#  "# Seedlings", "short", "med", "long", "Duff Depth Avg. (mm)" 


seedling_join <- left_join(x = measurement_period_stats, 
          y = seedling, by = "PlotName" )
#add row names to the dataset
row.names(seedling_join) <- row.names(measurement_period_stats)


# Fixing mistakes in Plot Info-------------------------------------
#plots that are not given the proper plot information will not be joined with the right HOBO data.

#Units without seedling information
missing  <- seedling_join[is.na(seedling_join$seedlings),]

#exclude the units without location information
missing <- missing[!is.na(missing$PlotName), ]

#remove Rep letter and see if there is a match in the seedling dataframe 
missing$PlotName <- missing$PlotName %>% str_remove_all("a") %>% str_remove_all("b")

#match PlotName to seedling plots 
sapply(missing$PlotName, function(x) which(str_detect(seedling$PlotName, x )))

#a single plot had a match. It appears there was a mistake in the documentation of the Rep 
#Change plot name from T7W1 -> T7W1b so we can match this HOBO unit to the seedling data

measurement_period_stats$PlotName[which(measurement_period_stats$PlotName == 'T7W1')] <- 'T7W1b'


#Run join again--------------------------------------------------------------------------
seedling_join <- left_join(x = measurement_period_stats, 
                           y = seedling, by = "PlotName" )
#add row names to the dataset
row.names(seedling_join) <- row.names(measurement_period_stats)

#check how many NAs are left (should now be equal to 11)
nrow(seedling_join %>% filter(!is.na(PlotName), is.na(seedlings))) 

#write csv file with this information for future analysis use 
write.csv(seedling_join,
        file = "./2016_Data/Hobo data/measurement_period_stats.csv")

#use following code to load dataset when revisiting the dataset for further edits
#seedling_join <- read.csv(file = "./2016_Data/Hobo data/measurement_period_stats.csv")

