#' ---
#' title: "Script for classifying the nondominated points"
#' author: "Lars Relund"
#' output:
#'    html_document:
#'      self_contained: true
#'      theme: united
#'      highlight: tango
#'      df_print: paged
#'      code_folding: show
#'      toc: true
#'      toc_float: true
#' ---

#+ include = FALSE
library(knitr)
knitr::opts_chunk$set(
   collapse = TRUE,
   comment = "#>", message=FALSE, include = TRUE,
   cache = TRUE, autodep = TRUE, error = TRUE, warning =  TRUE,
   out.width = "99%", fig.width = 8, fig.align = "center", fig.asp = 0.62
)
options(nwarnings = 10000)


#' This script is used to convert the program output to json result files (one for each instance).
#' All the program output is stored in the `data` subfolder
#'
#' Note set working dir to source file location when you work with the script.

#' ### Setup
#' Install packages:
# remotes::install_github("MCDMSociety/MOrepo/misc/R/MOrepoTools")
library(MOrepoTools)
library(tidyverse)
library(lubridate)
library(fs)
options(width = 100)
try(setwd("./results/convert"))
source("functions.R")

#' Get all instances
instances <- list.files("../../instances/raw/", recursive = T) %>%
   str_remove(".*/") %>% str_remove(".raw")
str(instances)

#' Read result output
dat <- read_csv("data/stat.csv", col_types = cols()) %>% rownames_to_column()
dat

start_time <- now()
# 2884,2924,2964,3004,3044
#' ### Update json files with classification of points
resJsonFiles <- list.files("..", ".json", full.names = T)
for (iName in unique(dat$instance)) {
   tmp <- dat %>% dplyr::filter(instance == iName)
   resFilesTmp <- grep(iName, resJsonFiles, value = T)
   classified <- F
   # message("\nDuration: ", now() - start_time,"\n")
   if (now() - start_time > 60*20) {message("\nStop script. Max time obtained."); break}
   if (length(resFilesTmp) > 0) {
      # message(iName,": ")
      # cat(iName, ": ", sep="")
      for (i in 1:nrow(tmp)) {
         mth1 <- paste0(tmp$nodesel[i], "_", tmp$varsel[i], "_", tolower(tmp$OB[i]))
         fileN <- paste0("../", iName, "_", mth1, "_result.json")
         if (!file_exists(fileN)) next
         message("File ", tmp$rowname[i], "/", nrow(dat), " | ", sep="")
         lst <- jsonlite::fromJSON(fileN)
         if (length(which(is.na(lst$points$type))) > 0 & lst$optimal) { # not classified yet
            if (!classified) {
               pts0 <- lst$points[,1:(ncol(lst$points)-1)] %>%
                  mutate(rowId = 1:nrow(.))
               pts <- classifyNDSet(pts0[,1:(ncol(pts0)-1)]) %>%
                  select(-(se:us), type = "cls")
               # print(pts)
               pts <- full_join(pts0, pts, by = c("z1", "z2", "z3")) %>%
                  arrange(rowId) %>% # so the order will be the same as in XE
                  select(contains("z"), type)
               classified = T
            }
            lst$points <- pts
            str <- jsonlite::toJSON(lst, auto_unbox = TRUE, pretty = TRUE, digits = NA, na = "null")
            readr::write_lines(str, fileN)
            # message("Now classified")
         } else {
            # message("Already classified")
            pts <- lst$points
            classified <- T
         }
      }
   } else warning("Error: Can't find result files for ", iName, "!", sep="")
}

warnings()


#' For how to compiling reports from R script see https://rmarkdown.rstudio.com/articles_report_from_r_script.html
