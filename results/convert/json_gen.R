### Script for converting result output to json format

options(width = 100, nwarnings = 10000)
setwd("./results/convert")
logF <- file("json_gen.log", open = "wt")
sink(logF, type = "message")
sink(logF, split = T, type = "output")
# remotes::install_github("MCDMSociety/MOrepo/misc/R/MOrepoTools")
library(MOrepoTools)
library(tidyverse)
library(jsonlite)
library(lubridate)
library(fs)
source("functions.R")


### Date of run
now()



#### Branch and bound results ####
### Get all instances
instances <- list.files("../../instances/raw/", recursive = T) %>%
   str_remove(".*/") %>% str_remove(".raw")
# str(instances)


### Read result output
dat <- read_csv("data/stat.csv", col_types = cols()) %>%
   arrange(instance, nodesel, varsel, OB) %>%
   rownames_to_column() %>%
   mutate(instance = str_remove(instance, ".raw"))
#' Read statistics from json files
datJson <- read_csv("../statistics.csv")


### Check if output consistent
# Remove all json files that don't have an instance
resJsonFiles <- list.files("..", ".json", full.names = F)
resJsonFiles <- tibble(fName = resJsonFiles, instance = str_replace(fName, "(^.*)_.+?_.+?_.+?_result.json$", "\\1")) %>% rownames_to_column()
inst <- tibble(instance = instances)
tmp <- inner_join(resJsonFiles, inst) %>% pull(rowname)
inst <- resJsonFiles %>%  filter(!(rowname %in% tmp)) %>% pull(fName)
inst <- str_c("../", inst)
message("Delete json files that don't have a corresponding instance:\n")
print(inst)
unlink(inst)

# Remove all json files that don't have results
resJsonFiles <- list.files("..", ".json", full.names = F) %>% str_remove("_result.json")
statFiles <- dat %>% mutate(fileN = str_c(instance, "_", nodesel, "_", varsel, "_", tolower(OB))) %>% pull(fileN)
if (length(resJsonFiles[!(resJsonFiles %in% statFiles)]) > 0) {
   files <- str_c("../", resJsonFiles[!(resJsonFiles %in% statFiles)], "_result.json")
   message("Delete old json files with no row in stat.csv:\n")
   print(files)
   unlink(files)
}


### File name functions
fNameYN <- function(instance) {
   instance <- str_remove(instance, ".raw")
   str_c("data/details/", instance, "_UB.txt")
}
fNameXE <- function(instance) {
   instance <- str_remove(instance, ".raw")
   str_c("data/details/", instance, "_XE.txt")
}
fNameUB <- function(instance, nodesel, varsel, ob) {
   instance <- str_remove(instance, ".raw")
   mth <- paste0(nodesel, "_", varsel, "_", tolower(ob)) %>%
      str_replace_all(c("breadth" = "b", "depth" = "d", "none" = "-2", "cone" = "1", "exact" = "2"))
   str_c("data/details/UBrun/", instance, "_", mth, "_UB.csv")
}
fNameJson <- function(instance, nodesel, varsel, ob) {
   instance <- str_remove(instance, ".raw")
   mth <- paste0(nodesel, "_", varsel, "_", tolower(ob))
   str_c("../", instance, "_result_", mth, ".json")
}


# message("\nCheck cpu times in data folder:\n")
# tmp <- read_csv("data/stat.csv", col_types = cols())
# for (i in 1:nrow(tmp)) {
#    fileN <- fNameUB(tmp$instance[i], tmp$nodesel[i], tmp$varsel[i], tmp$OB[i])
#    if (file.exists(fileN)) pts <- read_csv(fileN, col_types = cols())
#    else message("Error: File ", fileN, " doesn't exist but has a row in stat.csv! Old results?")
#    tmp %>% slice(i) %>% select(instance, nodesel, varsel, OB, tpstotal)
#    if (tmp$tpstotal[i] < pts$time[nrow(pts)] - 0.1)
#       message("Error: Last cpu time in UB set is higher than tpstotal in stat.csv (file: ", fileN, ", row: ", i, ")!")
# }


message("\nCreate json files with classification of points:\n")
MissingInstance <- function(iName) {
   if (!(iName %in% instances)) {
      message("Instance file is missing for ", iName, ". Skip generating json files!")
      return(TRUE)
   }
   return(FALSE)
}
MissingResultFiles <- function(iName, resFiles) {
   if (length(resFiles) == 0) {
      message("Result files for ", iName, " are missing!")
      return(TRUE)
   }
   return(FALSE)
}
ErrorCheckConfig <- function(iName, datConfig, fileNYN) {
   if (nrow(datConfig %>% dplyr::filter(solved == 1) %>% distinct(YN)) > 1) {
      message("Error: ", iName, ". Different number of nondominated points when compare exact solutions for different alg. configs in stat.csv!", sep="")
      return(TRUE)
   }
   if (!file.exists(fileNYN) & nrow(datConfig %>% dplyr::filter(solved == 1)) > 0) {
      message("Error: A config found an exact solution but ", fileNYN, " don't exists!", sep = "")
      return(TRUE)
   }
   return(FALSE)
}
ErrorCheckYN <- function(ptsYN, ptsUB, fileNYN, fileNUB) {
   if (nrow(ptsYN) != nrow(ptsUB)) {
      message("Error: Different number of ND points in ", fileNYN, " and ", fileNUB, " (solved = 1)!")
      return(TRUE)
   }
   return(FALSE)
}
ResultsAlreadyGen <- function(fileNJson) {
   if (file_exists(fileNJson)) {
      ## check if epsilon added
      # lst <- jsonlite::fromJSON(fileNJson)
      # if (is.null(lst$misc$inputStat$epsilon)) return(FALSE)
      ## check if cpu the same
      # cpu <- datJson %>% dplyr::filter(instance == iName, nodesel == tmp$nodesel[i], varsel == tmp$varsel[i], OB == tmp$OB[i]) %>% pull(tpstotal)
      # if (tmp$tpstotal[i] == cpu) next  # use cpu time as indicator for old reslut
      # message("Delete old ", fileNJson, " file (cpu not equal)!")
      # unlink(fileNJson)
      message("Already generated.")
      return(TRUE)
   }
   return(FALSE)
}

resFiles <- list.files(recursive = T)
start_time <- now()
regenerate <- FALSE
for (iName in unique(dat$instance)) {
   if (MissingInstance(iName)) next
   tmp <- dat %>% dplyr::filter(instance == iName)
   exactSolution <- nrow(tmp %>% dplyr::filter(solved==1)) > 0
   resFilesTmp <- grep(str_c(iName, "_"), resFiles, value = T)
   if (MissingResultFiles(iName, resFilesTmp)) next

   diff <- as.duration(now() - start_time)
   message("\nDuration: ", diff,"\n")
   if (diff > 60*30) {message("\nStop script. Max time obtained."); break}

   message("Instance: ", iName)
   for (i in 1:nrow(tmp)) {
      message("File ", tmp$rowname[i], "/", nrow(dat), " | ", appendLF = F)
      fileNYN <- fNameYN(iName)
      fileNJson <- fNameJson(iName, tmp$nodesel[i], tmp$varsel[i], tmp$OB[i])
      fileNUB <- fNameUB(iName, tmp$nodesel[i], tmp$varsel[i], tmp$OB[i])
      if (ErrorCheckConfig(iName, tmp, fileNYN)) next
      if (!regenerate & ResultsAlreadyGen(fileNJson)) next
      pts1 <- read_csv(fileNUB, col_types = cols())
      pts3 <- pts1[,1:tmp$p[i]]
      pts3 <- pts3 %>% mutate(type = NA)
      if (exactSolution) {
         pts0 <- read_csv(fileNYN, col_types = cols())[,1:tmp$p[1]] %>%
            mutate(rowId = 1:nrow(.))
         pts <- classifyNDSet(pts0[,1:(ncol(pts0)-1)]) %>%
            select(-(se:us), type = "cls")
         pts2 <- full_join(pts,pts1, by = c("z1", "z2", "z3"))
         if (tmp$solved[i] == 1) {
            if (ErrorCheckYN(pts, pts2, fileNYN, fileNUB)) next
            pts3 <- pts
         }
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
      mth1 <- paste0(tmp$nodesel[i], "_", tmp$varsel[i], "_", tolower(tmp$OB[i]))
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
      subFolderName <- paste0("../", sub("(.*)-(.*?)_(.*)", "\\2", iName))
      dir_create(subFolderName)
      jsonF <- grep(".json", dir_ls(), value = T)
      file_move(jsonF, subFolderName)
   }
}






#'
#'
#'    resFilesTmp <- grep(str_c(iName, "_"), resFiles, value = T)
#'    if (length(resFilesTmp) > 0) {
#'       # message(iName,": ")
#'       # message(iName, ": ", sep="")
#'       mth1 <- paste0(tmp$nodesel, "_", tmp$varsel, "_", tolower(tmp$OB))
#'       # if (all(file_exists(paste0("../", iName, "_", mth1, "_result.json")))) {
#'       #    # message("Already generated for all methods!\n")
#'       #    next
#'       # }
#'       if (nrow(tmp %>% dplyr::filter(solved == 1) %>% distinct(YN)) > 1) {
#'          message("Error: ", iName, ". Different number of nondominated points when compare exact solutions for different alg. configs!", sep="")
#'          next
#'       }
#'       diff <- as.duration(now() - start_time)
#'       message("\nDuration: ", diff,"\n")
#'       if (diff > 60*60) {message("\nStop script. Max time obtained."); break}
#'       fileNYN <- fNameYN(iName)
#'       if (!file.exists(fileNYN)) {
#'          message("Error: ", fileNYN, " don't exists!", sep = "")
#'          next
#'       }
#'       pts0 <- read_csv(fileNYN, col_types = cols())[,1:tmp$p[1]] %>%
#'          mutate(rowId = 1:nrow(.))
#'       # pts <- pts0 %>% mutate(type = NA) %>% select(contains("z"), type)
#'       pts <- classifyNDSet(pts0[,1:(ncol(pts0)-1)]) %>%
#'          select(-(se:us), type = "cls")
#'       # pts <- full_join(pts0, pts, by = c("z1", "z2", "z3")) %>%
#'       #    arrange(rowId) %>% # so the order will be the same as in XE
#'       #    select(contains("z"), type)
#'       # coeff <- read_csv(grep(str_c(iName,"_coef"), resFiles, value = T))
#'       # coeffRatio <- sum(coeff$nondominated)/nrow(coeff)
#'       for (i in 1:nrow(tmp)) {
#'          message("File ", tmp$rowname[i], "/", nrow(dat), " | ")
#'          mth1 <- paste0(tmp$nodesel[i], "_", tmp$varsel[i], "_", tolower(tmp$OB[i]))
#'          mth <- mth1 %>%
#'             str_replace_all(c("breadth" = "b", "depth" = "d", "none" = "-2", "cone" = "1", "exact" = "2"))
#'          # message(tmp$rowname[i],": ", mth, "  ", sep="")
#'          fileNJson <- fNameJson(iName, tmp$nodesel[i], tmp$varsel[i], tmp$OB[i])
#'          # if (file_exists(fileNJson)) {
#'          #    cpu <- datJson %>% dplyr::filter(instance == iName, nodesel == tmp$nodesel[i], varsel == tmp$varsel[i], OB == tmp$OB[i]) %>% pull(tpstotal)
#'          #    if (tmp$tpstotal[i] == cpu) next  # use cpu time as indicator for old reslut
#'          #    message("Delete old ", fileNJson, " file (cpu not equal)!")
#'          #    unlink(fileNJson)
#'          # }
#'          # if (round(coeffRatio,3) != round(tmp$ratioNDcoef[i], 3)) message("Tjeck error: Ratio not the same!", coeffRatio, "!>", tmp$ratioNDcoef)
#'          fileNUB <- fNameUB(iName, tmp$nodesel[i], tmp$varsel[i], tmp$OB[i])
#'          pts1 <- read_csv(fileNUB, col_types = cols())
#'          pts2 <- full_join(pts,pts1, by = c("z1", "z2", "z3"))
#'          pts3 <- pts %>% slice(0)
#'          if (nrow(pts) != nrow(pts2) & tmp$solved[i] == 1) {
#'             message("Error: Different number of ND points in ",
#'                     grep(str_c(iName, "_", mth), resFilesTmp, value = T), " compared to UB set (solved = 1)!")
#'             next
#'          }
#'          if (nrow(pts) == nrow(pts2)) pts3 <- pts
#'          if (tmp$solved[i] == 0) {
#'             pts3 <- pts1[,1:tmp$p[i]]
#'             pts3 <- pts3 %>% mutate(type = NA)
#'             # pts3 <- addNDSet(pts3) %>% select(-(nd:us), type = "cls")
#'          }
#'          if (nrow(pts3) != tmp$YN[i]) {
#'             message("Error: Number of nondominated points and YN are not equal in ",
#'                      grep(str_c(iName, "_", mth), resFilesTmp, value = T), "!")
#'             next
#'          }
#'          misc <- list(
#'             algConfig = tmp %>% select(nodesel:OB) %>% slice(i) %>% as.list(),
#'             inputStat = list(
#'                n = tmp$n[i], coeffNDRatio = tmp$ratioNDcoef[i], coeffGenMethod = tmp$coef[i],
#'                epsilon = tmp$epsilon[i],
#'                coeffRange = c(tmp$rangemin[i], tmp$rangemax[i])),
#'             outputStat = tmp %>% select(nbnodes:maxnbpbOB) %>% slice(i) %>% as.list())
#'          if (tmp$solved[i] == 1) misc$xE = read_csv(fNameXE(iName), col_types = cols())
#'          misc$outputStat$yNStat <- pts1
#'          try(createResultFile(
#'             instanceName = iName,
#'             other = mth1,
#'             contributionName = "Forget20",
#'             objectives = dat$p[i],
#'             objectiveType = rep("int", dat$p[i]),
#'             direction = rep("min", dat$p[i]),
#'             cpu = c(sec = tmp$tpstotal[i], machineSpec = "Intel i7-4785T 2.20 GHz, 15.6 GB RAM, Ubuntu 14.04 LTS 64 bit"),
#'             points = pts3,
#'             card = tmp$YN[i],
#'             suppCard = nrow(dplyr::filter(pts3, type == "se" | type == "sne")),
#'             extCard = nrow(dplyr::filter(pts3, type == "se")),
#'             comments = paste0("Instance solved using config ", mth1),
#'             optimal = if_else(tmp$solved[i] == 1, TRUE, FALSE),
#'             # we add all other things under misc
#'             misc = misc
#'          ))
#'          #' Move the file
#'          jsonF <- grep(".json", dir_ls(), value = T)
#'          file_move(jsonF, paste0("../",jsonF))
#'       }
#'    } else message("Error: Can't find result files for ", iName, "!", sep="")
#'    # message("\n")
#' }

#### Objective space search results (OSS) ####










#### Close files ####

warnings()
sink(type = "message")
sink()


