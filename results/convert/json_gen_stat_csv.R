### Script for generating statistics.csv

options(width = 100, nwarnings = 10000)
try(setwd("./results/convert"))
logF <- file("json_gen_stat_csv.log", open = "wt")
sink(logF, type = "message")
sink(logF, split = T, type = "output")

#' This script is used to generate the aggregated statistics stored in `statistics.csv` in the
#' `results` subfolder
#'
#' Note set working dir to source file location when you work with the script.

#### Setup ####
# remotes::install_github("MCDMSociety/MOrepo/misc/R/MOrepoTools")
library(tidyverse)
library(jsonlite)
library(lubridate)
options(width = 100)

### Run date
now()

#### Branch and bound results ####
message("Add lines to statistics.csv:")
resJsonFiles <- list.files("..", ".json", full.names = T, recursive = TRUE)
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

datOSS <- read_csv("data/statOSS.csv", col_types = cols()) %>%
   arrange(instance) %>%
   # filter(solved == 1) %>%
   rownames_to_column()

## Check same number of solutions
datJoin <- right_join(dat, datOSS %>% filter(solved == 1), by = c("instance")) %>%
   filter(YN.x != YN.y) %>%
   mutate(errTxt = str_c("Error (", instance, "): YN not same size (B&B=", YN.x, " OSS=", YN.y,")"))
cat(str_c(datJoin$errTxt, collapse = "\n"))

datOSS <- datOSS %>%
   filter(!(rowname %in% datJoin$rowname.y)) %>%
   select(-rowname)
write_csv(datOSS, "../statistics_oss.csv")




#### Cpu times nd points ####

message("Add lines to statistics_nd_points.csv:")
resJsonFiles <- list.files("..", ".json", full.names = T, recursive = T) %>%
   str_subset("spheredown") %>%
   str_subset("mof") %>%
   str_subset("1-1000")
dat <- NULL
lgd <- length(resJsonFiles)
j <- 0
for (i in 1:lgd) {
   message("File ", i, "/", lgd, "): ", resJsonFiles[i], " | ", appendLF = F)
   lst <- jsonlite::fromJSON(resJsonFiles[i])
   if (lst$optimal) {
      algConfig <- tolower(str_c(unlist(lst$misc$algConfig), collapse = "_"))
      res <- lst$misc$outputStat$yNStat
      instance <- lst$instanceName
      maxDepth <- max(res$depth)
      dat <- bind_rows(dat,
                       tibble(instance = instance,
                              algConfig = algConfig,
                              tpstotal = lst$cpu$sec,
                              maxDepth = maxDepth,
                              resUB = list(as_tibble(res))))
   }
   if (object.size(dat) > 6000000 | i == lgd) {
      dat <- dat %>%
         group_by(instance, algConfig) %>%
         mutate(relativeSolved =
                   pmap(list(resUB, tpstotal, algConfig, maxDepth),
                        function(df = ..1, cpuT = ..2, mth = ..3, depthM = ..4) {
                           # if (nrow(df) > 1) {
                           res <- tibble(mth = mth,
                                         pct = c(nrow(df),  rep(nrow(df), nrow(df)), nrow(df)),
                                         cpu = c(0, df$time, cpuT),
                                         depth = c(0, df$depth, depthM),
                                         rowname = 1:(nrow(df)+2))
                           res <- res %>% mutate(pct = (rowname-1)/pct) %>% select(-rowname)
                           res[nrow(res),"pct"] <- 1
                           # res <- res %>% arrange(pct, cpu)
                           # } else {
                           # res <- tibble(mth = mth, pct = c(1, cpu = c(df$time, cpuT), rowname = 1:2)
                           # }
                           res %>% mutate(pctCpu = cpu/cpuT, pctDepth = depth/depthM)
                        })) %>%
         unnest(relativeSolved) %>%
         select(-resUB, -mth)
      write_csv(dat, str_c("../statistics_nd_points_", j, ".csv"))
      j <- j + 1
      dat <- NULL
   }
}

message("\nFinished.\n")


#### Cpu times nd points OSS ####

message("Add lines to statistics_points_oss.csv:")

# B&B instances
csvFiles <- list.files("..", ".csv", full.names = T) %>%
   str_subset("nd")
dat <- NULL
for (f in csvFiles) dat <- bind_rows(dat, read_csv(f))
instancesBB <- unique(dat$instance)

datOSS <- read_csv("../statistics_oss.csv") %>%
   mutate(fName = str_c("data/UB_OSS/", instance, "_OSS_UB.txt"))
dat <- NULL
lgd <- nrow(datOSS)
j <- 0
for (i in 1:lgd) {
   message("File ", i, "/", lgd, "): ", datOSS$instance[i], " | ", appendLF = F)
   res <- read_csv(datOSS$fName[i])
   algConfig <- "OSS"
   instance <- datOSS$instance[i]
   tpstotal <- datOSS$cpu[i]
   dat <- bind_rows(dat,
                    tibble(instance = instance,
                           algConfig = algConfig,
                           tpstotal = tpstotal,
                           maxDepth = NA,
                           resUB = list(as_tibble(res))))

   if (object.size(dat) > 6000000 | i == lgd) {
      dat <- dat %>%
         group_by(instance, algConfig) %>%
         mutate(relativeSolved =
                   pmap(list(resUB, tpstotal, algConfig, maxDepth),
                        function(df = ..1, cpuT = ..2, mth = ..3, depthM = ..4) {
                           # if (nrow(df) > 1) {
                           res <- tibble(mth = mth,
                                         pct = c(nrow(df),  rep(nrow(df), nrow(df)), nrow(df)),
                                         cpu = c(0, df$time, cpuT),
                                         depth = NA,
                                         rowname = 1:(nrow(df)+2))
                           res <- res %>% mutate(pct = (rowname-1)/pct) %>% select(-rowname)
                           res[nrow(res),"pct"] <- 1
                           res %>% mutate(pctCpu = cpu/cpuT, pctDepth = NA)
                        })) %>%
         unnest(relativeSolved) %>%
         select(-resUB, -mth)
      write_csv(dat, str_c("../statistics_points_oss_", j, ".csv"))
      j <- j + 1
      dat <- NULL
   }
}

message("\nFinished.\n")



#### Clean and Finish ####

warnings()
sink(type = "message")
sink()
