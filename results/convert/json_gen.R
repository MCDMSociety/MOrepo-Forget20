#' ---
#' title: "Script for converting result output to the right json format"
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
sink("json_gen.log", append=F, split=T)

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

#' Get all instances
instances <- list.files("../../instances/raw/", recursive = T) %>%
   str_remove(".*/") %>% str_remove(".raw")
# str(instances)

#' Read result output
dat <- read_csv("data/stat.csv", col_types = cols()) %>% rownames_to_column()
# dat



#' ### Check if output consistent
#' #### Different tests on each instance?
tmp <- dat %>% group_by(instance) %>% summarise(count = n())
unique(tmp$count)
#' An example:
dat %>% dplyr::filter(instance == tmp$instance[1])
#' That is the tests differ in `nodesel` and `varsel`.

#' #### Do all results have an instance file?
tmp <- tibble(instance = instances)
nrow(dat) == nrow(dat %>% full_join(tmp))

#' #### Do all methods find exact solution?
tmp <- dat %>% group_by(instance, solved) %>% nest() %>% dplyr::filter(solved == 0)
nrow(tmp) == 0



#' ### Create json files with classification of points
#' All result files are in csv format with comma delimitor and dot as decimal mark.
resFiles <- list.files(recursive = T)
start_time <- now()
for (iName in unique(dat$instance)) {
   tmp <- dat %>% dplyr::filter(instance == iName)
   resFilesTmp <- grep(iName, resFiles, value = T)
   if (length(resFilesTmp) > 0) {
      # message(iName,": ")
      # cat(iName, ": ", sep="")
      mth1 <- paste0(tmp$nodesel, "_", tmp$varsel, "_", tolower(tmp$OB))
      if (all(file_exists(paste0("../", iName, "_", mth1, "_result.json")))) {
         # cat("Already generated for all methods!\n")
         next
      }
      if (nrow(tmp %>% dplyr::filter(solved == 1) %>% distinct(YN)) > 1) {
         warning("Error: ", iName, ". Different number of nondominated points when compare exact solutions for different alg. configs!", sep="")
         next
      }
      diff <- as.duration(now() - start_time)
      message("\nDuration: ", diff,"\n")
      if (diff > 60*10) {message("\nStop script. Max time obtained."); break}
      if (length(grep(str_c(iName,"_UB"), resFiles, value = T)) == 0) {
         warning("Error: ", iName, "_UB don't exists!", sep = "")
         next
      }
      pts0 <- read_csv(grep(str_c(iName,"_UB"), resFiles, value = T), col_types = cols())[,1:tmp$p[1]] %>%
         mutate(rowId = 1:nrow(.))
      # pts <- pts0 %>% mutate(type = NA) %>% select(contains("z"), type)
      pts <- classifyNDSet(pts0[,1:(ncol(pts0)-1)]) %>%
         select(-(se:us), type = "cls")
      # pts <- full_join(pts0, pts, by = c("z1", "z2", "z3")) %>%
      #    arrange(rowId) %>% # so the order will be the same as in XE
      #    select(contains("z"), type)
      # coeff <- read_csv(grep(str_c(iName,"_coef"), resFiles, value = T))
      # coeffRatio <- sum(coeff$nondominated)/nrow(coeff)
      for (i in 1:nrow(tmp)) {
         message("File ", tmp$rowname[i], "/", nrow(dat), " | ")
         mth1 <- paste0(tmp$nodesel[i], "_", tmp$varsel[i], "_", tolower(tmp$OB[i]))
         mth <- mth1 %>%
            str_replace_all(c("breadth" = "b", "depth" = "d", "none" = "-2", "cone" = "1", "exact" = "-2"))
         # cat(tmp$rowname[i],": ", mth, "  ", sep="")
         if (file_exists(paste0("../", iName, "_", mth1, "_result.json"))) {
            # cat("Already generated! ")
            next
         }
         # if (round(coeffRatio,3) != round(tmp$ratioNDcoef[i], 3)) warning("Tjeck error: Ratio not the same!", coeffRatio, "!>", tmp$ratioNDcoef)
         pts1 <- read_csv(grep(str_c(iName, "_", mth), resFilesTmp, value = T), col_types = cols())
         pts2 <- full_join(pts,pts1, by = c("z1", "z2", "z3"))
         pts3 <- pts %>% slice(0)
         if (nrow(pts) != nrow(pts2) & tmp$solved[i] == 1) {
            warning("Error: Different number of ND points in ",
                    grep(str_c(iName, "_", mth), resFilesTmp, value = T), " compared to UB set (solved = 1)!")
            next
         }
         if (nrow(pts) == nrow(pts2)) pts3 <- pts
         if (tmp$solved[i] == 0) {
            pts3 <- pts1[,1:tmp$p[i]]
            pts3 <- pts3 %>% mutate(type = NA)
            # pts3 <- addNDSet(pts3) %>% select(-(nd:us), type = "cls")
         }
         if (nrow(pts3) != tmp$YN[i]) {
            warning("Error: Number of nondominated points and YN are not equal in ",
                     grep(str_c(iName, "_", mth), resFilesTmp, value = T), "!")
            next
         }
         misc <- list(
            algConfig = tmp %>% select(nodesel:OB) %>% slice(i) %>% as.list(),
            inputStat = list(
               n = tmp$n[i], coeffNDRatio = tmp$ratioNDcoef[i], coeffGenMethod = tmp$coef[i],
               coeffRange = c(tmp$rangemin[i], tmp$rangemax[i])),
            outputStat = tmp %>% select(nbnodes:maxnbpbOB) %>% slice(i) %>% as.list())
         if (tmp$solved[i] == 1) misc$xE = read_csv(grep(str_c(iName,"_XE"), resFiles, value = T), col_types = cols())
         misc$outputStat$yNStat <- pts1
         try(createResultFile(
            instanceName = iName,
            other = mth1,
            contributionName = "Forget20",
            objectives = dat$p[i],
            objectiveType = rep("int", dat$p[i]),
            direction = rep("min", dat$p[i]),
            cpu = c(sec = tmp$tpstotal[i], machineSpec = "Intel i7-4785T 2.20 GHz, 15.6 GB RAM, Ubuntu 14.04 LTS 64 bit"),
            points = pts3,
            card = tmp$YN[i],
            suppCard = nrow(dplyr::filter(pts3, type == "se" | type == "sne")),
            extCard = nrow(dplyr::filter(pts3, type == "us")),
            comments = paste0("Instance solved using config ", mth1),
            optimal = if_else(tmp$solved[i] == 1, TRUE, FALSE),
            # we add all other things under misc
            misc = misc
         ))
         #' Move the file
         jsonF <- grep(".json", dir_ls(), value = T)
         file_move(jsonF, paste0("../",jsonF))
      }
   } else warning("Error: Can't find result files for ", iName, "!", sep="")
   cat("\n")
}

warnings()
sink()

#' For how to compiling reports from R script see https://rmarkdown.rstudio.com/articles_report_from_r_script.html
