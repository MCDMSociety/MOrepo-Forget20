#' ---
#' title: "Script for converting result output to the right json format"
#' author: ""
#' ---

#' This script is used to convert the program output to json result files (one for each instance).
#' All the program output is stored in the `data` subfolder
#'
#' [Add a short desc of what the output files contain (don't have to be to detailed)]
#'
#'

## Note set working dir to source file location
# remotes::install_github("MCDMSociety/MOrepo/misc/R/MOrepoTools")
library(MOrepoTools)
library(gMOIP)
library(tidyverse)

instances <- list.files("../../instances/raw/", recursive = T) %>%
   str_remove(".*/") %>% str_remove(".raw")




dat <- read_csv("data/stat.csv")

idx <- c(2001 , 2002 , 2003 , 2004 , 2009 , 2010 , 2011 , 2012 , 3441 , 3442 , 3443 , 3444 , 3449 , 3450 , 3451 , 3452 , 6321 , 6322 , 6323 , 6324 , 6329 , 6330 , 6331 , 6332 , 7041 , 7042 , 7043 , 7044 , 7049 , 7050 , 7051 , 7052)


# all result files are in csv format with comma delimitor and dot as decimal mark
resFiles <- list.files(recursive = T)
# for (i in idx) {  # 1:nrow(dat)
   # # must load the correct results here
   # pts <- data.frame(z1 = c(27, 30, 31, 34, 42, 43, 49, 51), z2 = c(56, 53, 36, 33, 30, 25, 23, 9),
   #    type = c('se', 'us', 'se', 'us', 'us', 'us', 'us', 'se'))


   i = 2001
   iName <- dat$instance[i]
   # iName <- "KP_10_3_2box_1_10_1"
   # if (length(grep(iName, resFiles, value = T)) >0 ) cat(i,", ")

   # fs <- grep(iName, resFiles, value = T)
   # file.show(fs, pager = "RStudio")


   pts <- read_csv(grep(str_c(iName,"_UB.csv"), resFiles, value = T))[,1:dat$p[i]]
   pts <- addNDSet(pts) %>% select(-(nd:us), type = "cls")
   if (nrow(pts) != dat$YN[i]) stop("Different number of nondominated points!")

   coeff <- read_csv(grep(str_c(iName,"_coef.csv"), resFiles, value = T))
   coeffRatio <- sum(coeff$nondominated)/nrow(coeff)

   createResultFile(
      instanceName = dat$instance[i],
      contributionName = "Forget20",
      objectives = dat$p[i],
      objectiveType = rep("int", dat$p[i]),
      direction = rep("min", dat$p[i]),
      cpu = c(sec = 3, machineSpec = "Intel ..."),
      points = pts,
      card = dat$YN[i],
      suppCard = nrow(dplyr::filter(pts, type == "se" | type == "sne")),
      extCard = nrow(dplyr::filter(pts, type == "us")),
      comments = "",
      optimal = TRUE,
      # we add all other things under misc
      misc = list(inputStat = list(n = dat$n[i], coeffRatio = coeffRatio),
                  outputStat = list(),
                  xE = read_csv(grep(str_c(iName,"_XE.csv"), resFiles, value = T)))
   )
# }


#' For how to compiling reports from R script see https://rmarkdown.rstudio.com/articles_report_from_r_script.html
