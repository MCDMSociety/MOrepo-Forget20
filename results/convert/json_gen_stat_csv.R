### Script for generating statistics.csv

options(width = 100, nwarnings = 10000)
setwd("./results/convert")
logF <- file("json_gen_stat_csv.log", open = "wt")
sink(logF, type = "message")
sink(logF, split = T, type = "output")

#' This script is used to generate the aggregated statistics stored in `statistics.csv` in the
#' `results` subfolder
#'
#' Note set working dir to source file location when you work with the script.

#' ### Setup
#' Install packages:
# remotes::install_github("MCDMSociety/MOrepo/misc/R/MOrepoTools")
library(tidyverse)
library(jsonlite)
library(lubridate)
options(width = 100)

### Run date
now()

#### Branch and bound results ####
message("Add lines to statistics.csv:")
resJsonFiles <- list.files("..", ".json", full.names = T)
dat <- NULL
for (i in 1:length(resJsonFiles)) {
   message("File: ", resJsonFiles[i], " | ", appendLF = F)
   lst <- jsonlite::fromJSON(resJsonFiles[i])
   outS <- lst$misc$outputStat
   outS$yNStat <- NULL
   outS <- unlist(outS)
   rng <- str_c("[", lst$misc$inputStat$coeffRange[1], ",", lst$misc$inputStat$coeffRange[2], "]")
   pC <- str_replace(lst$instanceName, '(^.*?)-(.*?)_(.*$)', '\\2')
   if (pC == "UFLP") {
      rng = str_c("[", str_replace(lst$instanceName, '(^.*?)-(.*?)_(.*?)_(.*?)_(.*?_.*?)_(.*$)', '\\5'), "]")
      rng = str_replace_all(rng, c("_" = "]|[", "-" = ","))
   }
   res <- c(
      instance = lst$instanceName,
      namePrefix = str_replace(lst$instanceName, '(.*)_(.*)(_.?.?$)', '\\1'),
      insId = str_replace(lst$instanceName, '(.*_)(.*$)', '\\2'),
      constId = str_replace(lst$instanceName, '(.*)_(.*)(_.?.?$)', '\\2'),
      pb = pC,
      n = lst$misc$inputStat$n,
      p = lst$objectives,
      coef = lst$misc$inputStat$coeffGenMethod,
      rangeC = rng,
      rangeGapC = lst$misc$inputStat$coeffRange[2] - lst$misc$inputStat$coeffRange[1],
      nodesel = lst$misc$algConfig$nodesel,
      varsel = lst$misc$algConfig$varsel,
      OB = lst$misc$algConfig$OB,
      solved = lst$optimal,
      YN = lst$card,
      YNse = lst$extCard,
      YNs = lst$suppCard,
      YNus = lst$Card - lst$suppCard,
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
message("\nFinished.\nWrite to csv.")

# dat
# dat <- type_convert(dat)
write_csv(dat, "../statistics.csv")



#### Objective space search results (OSS) ####

dat <- read_csv("data/stat.csv", col_types = cols()) %>%
   mutate(instance = str_remove(instance, ".raw")) %>%
   arrange(instance, nodesel, varsel, OB) %>%
   filter(solved == 1) %>%
   group_by(instance) %>%
   slice(1) %>%
   rownames_to_column()
datOSS <- read_csv("data/stat_OSS.csv", col_types = cols()) %>%
   arrange(instance) %>%
   filter(solved == 1) %>%
   rownames_to_column()

## Check same number of solutions
datJoin <- right_join(dat, datOSS, by = c("instance")) %>%
   filter(YN.x != YN.y) %>%
   mutate(errTxt = str_c("Error (", instance, "): YN not same size (B&B=", YN.x, " OSS=", YN.y,")"))
cat(str_c(datJoin$errTxt, collapse = "\n"))

datOSS <- datOSS %>%
   filter(!(rowname %in% datJoin$rowname.y))
write_csv(dat, "../statistics_oss.csv")



warnings()
sink(type = "message")
sink()
