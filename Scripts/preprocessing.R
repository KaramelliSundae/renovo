#!~/.conda/envs/renovo/bin/R
#### fix the dataset, with median to reconstruct the NA

# get directory of the script
initial.options <- commandArgs(trailingOnly = FALSE)
file.arg.name <- "--file="
script.name <- sub(file.arg.name, "", initial.options[grep(file.arg.name, initial.options)])
script_dir <- dirname(script.name)

# Get cmdline arguments
args <- commandArgs(trailingOnly=TRUE)

# Paths from cmdline arguments
path <- args[1]
temp_dir <- args[2]

# Install necessary packages if they aren't alreay installed
if (!requireNamespace("openxlsx", quietly = TRUE))
	install.packages('openxlsx', repos='http://cran.us.r-project.org')

if (!requireNamespace("tidyverse", quietly = TRUE))
	install.packages("tidyverse", repos='http://cran.us.r-project.org')

if (!requireNamespace("readxl", quietly = TRUE))
	install.packages("readxl", repos='http://cran.us.r-project.org')

#if (!requireNamespace("vroom", quietly = TRUE)) # TODO
#	install.packages("vroom")

# Load required libs
library(openxlsx)
library(tidyverse)
library(readxl)
#library(vroom) # TODO

#upload functions, files
source(paste0(script_dir, "/FixData_median.R"))
median<- read_excel(paste0(script_dir, "/../Files/median_correct.xlsx"))

#paths

#input_file_path = paste0(path,file_name)
input_file_path = path
output_file_temp = paste0(temp_dir,"/input_RF.tab")

# Read input file
#input file: input_file #?
input_file<- read.delim(input_file_path, na.strings=".", stringsAsFactors=FALSE,header=TRUE) # TODO replace with vroom check columns casting

#Replace spaces with underscores in the ExonicFunc.refgene column
input_file$ExonicFunc.refGene<-gsub(" ","_",input_file$ExonicFunc.refGene,fixed=TRUE)

# Apply fix to data using "Fixdata_median" function and median substitution values
input_RF<-FixData_median(input_file,median)

# Remove rows with certain types
input_RF<-subset(input_RF,!(Type %in% c("exonic.NA","exonic;splicing.NA")))

# Write the fixed data to a temporary output file
write.table(input_RF,output_file_temp,
	sep="\t",
	eol="\n",
	quote=FALSE,
	col.names=TRUE,
	row.names=FALSE)
