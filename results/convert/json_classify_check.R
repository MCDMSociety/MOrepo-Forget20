#' ---
#' title: "Script for checking if classification of the nondominated points is correct"
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
sink("results/convert/json_classify_check.log", append=F, split=T)


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
setwd("./results/convert")
source("functions.R")
now()

#' Read result output
dat <- read_csv("data/stat.csv", col_types = cols()) %>% rownames_to_column()
# dat

# start_time <- now()
#' ### Check classification of points
for (iName in unique(dat$instance)) {
   fileNCsv <- str_c("data/details/", iName, "_UB.txt")
   if (!file_exists(fileNCsv)) next
   pts <- read_csv(fileNCsv, col_types = cols())[,1:3]
   tmp <- dat %>% dplyr::filter(instance == iName)
   # if (now() - start_time > 60*20) {message("\nStop script. Max time obtained."); break}
   message("\n", iName,": ", appendLF = F)
   for (i in 1:nrow(tmp)) {
      message("File ", tmp$rowname[i], "/", nrow(dat), "", sep="", appendLF = F)
      mth1 <- paste0(tmp$nodesel[i], "_", tmp$varsel[i], "_", tolower(tmp$OB[i]))
      mth <- mth1 %>%
         str_replace_all(c("breadth" = "b", "depth" = "d", "none" = "-2", "cone" = "1", "exact" = "2"))
      fileNJson <- paste0("../", iName, "_", mth1, "_result.json")
      if (!file_exists(fileNJson)) next
      lst <- jsonlite::fromJSON(fileNJson)
      if (length(which(is.na(lst$points$type))) == 0 & lst$optimal) { # classified
         pts1 <- lst$points[,1:3]
         pts2 <- full_join(pts1, pts, by = c("z1", "z2", "z3"))
         if (nrow(pts) != nrow(pts2)) {
            message ("\nError: Not same solutions! Recalc.")
            pts3 <- classifyNDSet(pts) %>%
               select(-(se:us), type = "cls")
            lst$points <- pts
            str <- jsonlite::toJSON(lst, auto_unbox = TRUE, pretty = TRUE, digits = NA, na = "null")
            readr::write_lines(str, fileNJson)
         } else {
            message(" - OK | ", appendLF = F)
         }
      } else {message(" - Skip | ", appendLF = F)}
   }
}

warnings()
sink()

#' For how to compiling reports from R script see https://rmarkdown.rstudio.com/articles_report_from_r_script.html
