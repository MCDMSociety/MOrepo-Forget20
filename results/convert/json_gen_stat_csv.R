#' ---
#' title: "Script for generating statistics.csv"
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


#' This script is used to generate the aggregated statistics stored in `statistics.csv` in the
#' `results` subfolder
#'
#' Note set working dir to source file location when you work with the script.

#' ### Setup
#' Install packages:
# remotes::install_github("MCDMSociety/MOrepo/misc/R/MOrepoTools")
library(tidyverse)
library(jsonlite)
options(width = 100)
setwd("./results/convert")

resJsonFiles <- list.files("..", ".json", full.names = T)
dat <- NULL
for (i in 1:10) {
   lst <- jsonlite::fromJSON(resJsonFiles[i])
   outS <- lst$misc$outputStat
   outS$yNStat <- NULL
   outS <- unlist(outS)
   res <- c(
      instance = lst$instanceName,
      namePrefix = str_replace(lst$instanceName, '(.*)_(.*)(_.?.?$)', '\\1'),
      insId = str_replace(lst$instanceName, '(.*_)(.*$)', '\\2'),
      constId = str_replace(lst$instanceName, '(.*)_(.*)(_.?.?$)', '\\2'),
      pb = str_replace(lst$instanceName, '(^.*?)-(.*?)_(.*$)', '\\2'),
      n = lst$misc$inputStat$n,
      p = lst$objectives,
      coef = lst$misc$inputStat$coeffGenMethod,
      rangeC = str_c("[", lst$misc$inputStat$coeffRange[1], ",", lst$misc$inputStat$coeffRange[2], "]"),
      rangeGapC = lst$misc$inputStat$coeffRange[2] - lst$misc$inputStat$coeffRange[1],
      nodesel = lst$misc$algConfig$nodesel,
      varsel = lst$misc$algConfig$varsel,
      OB = lst$misc$algConfig$OB,
      solved = lst$optimal,
      YN = lst$card,
      rangeZ1 = str_c("[", min(lst$points$z1), ",", max(lst$points$z1), "]"),
      rangeGapZ1 = max(lst$points$z1) - min(lst$points$z1),
      rangeZ2 = str_c("[", min(lst$points$z2), ",", max(lst$points$z2), "]"),
      rangeGapZ2 = max(lst$points$z2) - min(lst$points$z2),
      rangeZ3 = str_c("[", min(lst$points$z3), ",", max(lst$points$z3), "]"),
      rangeGapZ3 = max(lst$points$z3) - min(lst$points$z3),
      ratioNDcoef = lst$misc$inputStat$coeffNDRatio,
      outS
   )
   dat <- bind_rows(dat, res)
}
dat <- type_convert(dat)
write_csv(dat, "../statistics.csv")
warnings()

#' For how to compiling reports from R script see https://rmarkdown.rstudio.com/articles_report_from_r_script.html
