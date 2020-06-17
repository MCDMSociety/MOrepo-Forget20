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
sink("results/convert/json_gen.log", append=F, split=T)

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

#' Get all instances
instances <- list.files("../../instances/raw/", recursive = T) %>%
   str_remove(".*/") %>% str_remove(".raw")
# str(instances)

#' Read result output
dat <- read_csv("data/stat.csv", col_types = cols()) %>% arrange(instance, nodesel, varsel, OB) %>% rownames_to_column()
#' Read statistics from json files
datJson <- read_csv("../statistics.csv")


#' ### Check if output consistent

#' Remove all json files that don't have an instance
resJsonFiles <- list.files("..", ".json", full.names = F)
resJsonFiles <- tibble(fName = resJsonFiles, instance = str_replace(fName, "(^.*)_.+?_.+?_.+?_result.json$", "\\1")) %>% rownames_to_column()
inst <- tibble(instance = instances)
tmp <- inner_join(resJsonFiles, inst) %>% pull(rowname)
inst <- resJsonFiles %>%  filter(!(rowname %in% tmp)) %>% pull(fName)
inst <- str_c("../", inst)
cat("Delete json files that don't have a corresponding instance:\n")
print(inst)
unlink(inst)

#' Remove all json files that don't have results
resJsonFiles <- list.files("..", ".json", full.names = F) %>% str_remove("_result.json")
statFiles <- dat %>% mutate(fileN = str_c(instance, "_", nodesel, "_", varsel, "_", tolower(OB))) %>% pull(fileN)
if (length(resJsonFiles[!(resJsonFiles %in% statFiles)]) > 0) {
   files <- str_c("../", resJsonFiles[!(resJsonFiles %in% statFiles)], "_result.json")
   cat("Delete old json files with no row in stat.csv:\n")
   print(files)
   unlink(files)
}


# File name functions
fNameYN <- function(instance) {
   str_c("data/details/", instance, "_UB.txt")
}
fNameXE <- function(instance) {
   str_c("data/details/", instance, "_XE.txt")
}
fNameUB <- function(instance, nodesel, varsel, ob) {
   mth <- paste0(nodesel, "_", varsel, "_", tolower(ob)) %>%
      str_replace_all(c("breadth" = "b", "depth" = "d", "none" = "-2", "cone" = "1", "exact" = "2"))
   str_c("data/details/UBrun/", instance, "_", mth, "_UB.csv")
}
fNameJson <- function(instance, nodesel, varsel, ob) {
   mth <- paste0(nodesel, "_", varsel, "_", tolower(ob))
   str_c("../", instance, "_", mth, "_results.json")
}

#' Check cpu times in data folder
tmp <- read_csv("data/stat.csv", col_types = cols())
for (i in 1:nrow(tmp)) {
   fileN <- fNameUB(tmp$instance[i], tmp$nodesel[i], tmp$varsel[i], tmp$OB[i])
   if (file.exists(fileN)) pts <- read_csv(fileN, col_types = cols())
   else return(warning("Error: File ", fileN, " doesn't exist but has a row in stat.csv! Old results?"))
   tmp %>% slice(i) %>% select(instance, nodesel, varsel, OB, tpstotal)
   if (tmp$tpstotal[i] < pts$time[nrow(pts)] - 0.1)
      warning("Error: Last cpu time in UB set is higher than tpstotal in stat.csv (file: ", fileN, ", row: ", i, ")!")
}



#' ### Create json files with classification of points
#' All result files are in csv format with comma delimitor and dot as decimal mark.
resFiles <- list.files(recursive = T)
start_time <- now()
for (iName in unique(dat$instance)) {
   tmp <- dat %>% dplyr::filter(instance == iName)
   if (!(iName %in% instances)) warning("Instance file is missing for ", iName, "!")
   resFilesTmp <- grep(str_c(iName, "_"), resFiles, value = T)
   if (length(resFilesTmp) > 0) {
      # message(iName,": ")
      # cat(iName, ": ", sep="")
      mth1 <- paste0(tmp$nodesel, "_", tmp$varsel, "_", tolower(tmp$OB))
      # if (all(file_exists(paste0("../", iName, "_", mth1, "_result.json")))) {
      #    # cat("Already generated for all methods!\n")
      #    next
      # }
      if (nrow(tmp %>% dplyr::filter(solved == 1) %>% distinct(YN)) > 1) {
         warning("Error: ", iName, ". Different number of nondominated points when compare exact solutions for different alg. configs!", sep="")
         next
      }
      diff <- as.duration(now() - start_time)
      message("\nDuration: ", diff,"\n")
      if (diff > 60*60) {warning("\nStop script. Max time obtained."); break}
      fileNYN <- fNameYN(iName)
      if (!file.exists(fileNYN)) {
         warning("Error: ", fileNYN, " don't exists!", sep = "")
         next
      }
      pts0 <- read_csv(fileNYN, col_types = cols())[,1:tmp$p[1]] %>%
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
            str_replace_all(c("breadth" = "b", "depth" = "d", "none" = "-2", "cone" = "1", "exact" = "2"))
         # cat(tmp$rowname[i],": ", mth, "  ", sep="")
         fileNJson <- fNameJson(iName, tmp$nodesel[i], tmp$varsel[i], tmp$OB[i])
         if (file_exists(fileNJson)) {
            cpu <- datJson %>% dplyr::filter(instance == iName, nodesel == tmp$nodesel[i], varsel == tmp$varsel[i], OB == tmp$OB[i]) %>% pull(tpstotal)
            if (tmp$tpstotal[i] == cpu) next  # use cpu time as indicator for old reslut
            warning("Delete old ", fileNJson, " file (cpu not equal)!")
            unlink(fileNJson)
         }
         # if (round(coeffRatio,3) != round(tmp$ratioNDcoef[i], 3)) warning("Tjeck error: Ratio not the same!", coeffRatio, "!>", tmp$ratioNDcoef)
         fileNUB <- fNameUB(iName, tmp$nodesel[i], tmp$varsel[i], tmp$OB[i])
         pts1 <- read_csv(fileNUB, col_types = cols())
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
               epsilon = tmp$epsilon[i],
               coeffRange = c(tmp$rangemin[i], tmp$rangemax[i])),
            outputStat = tmp %>% select(nbnodes:maxnbpbOB) %>% slice(i) %>% as.list())
         if (tmp$solved[i] == 1) misc$xE = read_csv(fNameXE(iName), col_types = cols())
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
            extCard = nrow(dplyr::filter(pts3, type == "se")),
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
   # cat("\n")
}

warnings()
sink()

#' For how to compiling reports from R script see https://rmarkdown.rstudio.com/articles_report_from_r_script.html
