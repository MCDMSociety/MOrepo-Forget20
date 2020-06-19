#### Main file for report generation
loadPackages <- function(packages) {
   newP <- packages[!(packages %in% installed.packages()[,"Package"])]
   if(length(newP)) install.packages(newP, repos = "http://cran.rstudio.com/")
   lapply(packages, library, character.only = TRUE)
   invisible(NULL)
}
loadPackages(c("tidyverse", "rmarkdown", "fs", "distill"))
# options(rgl.useNULL=TRUE)

oldDir <- setwd("./results/report")


### Generate reports for special instances
if (interactive()) {
   limSec <- c(0, 30*60)  # computation time limits (exclude instances with max cpu < limSec[1] or  min cpu > limSec[2])
   datAll <- read_csv("../statistics.csv") %>%   #"../convert/data/stat.csv"
      mutate(YNsRatio = YNs/YN,
             YNusRatio = 1-YNs/YN,
             YNsneRatio = (YNs-YNse)/YN,
             algConfig = tolower(str_c(nodesel, varsel, OB, sep="_")),
             resultName = str_c(instance, algConfig, sep="_"))
   algConfigs <- length(unique(datAll$algConfig))
   tmp <- datAll %>%
      group_by(instance) %>%
      summarise(minCpu = min(tpstotal), maxCpu = max(tpstotal)) %>%
      filter(maxCpu < limSec[1] | minCpu > limSec[2]) %>%
      pull(instance)

   datAll <- datAll %>%
      filter(!(instance %in% tmp)) %>%
      mutate(solved = if_else(tpstotal >= limSec[2] | solved == 0, 0, 1)) %>%
      group_by(instance) %>%
      filter(n() == algConfigs) %>%
      ungroup() %>%
      mutate(tpstotal = if_else(tpstotal >= limSec[2], limSec[2], tpstotal))
   datNotSolved <- datAll %>% filter(solved == 0)
   datSolved <- datAll %>% filter(solved == 1)
   tmp <- datAll %>%
      group_by(instance) %>%
      summarise_at(vars(contains(c("YN", "total", "solved"))), list(mean = mean, sd = sd, max = max), na.rm = TRUE)
   inst <- bind_rows(
      tmp %>% top_n(-3, YN_max),
      tmp %>% filter(solved_max == 1) %>% top_n(3, YN_max),
      tmp %>% filter(solved_max < 1) %>% top_n(3, YN_max),
      tmp %>% top_n(-3, YNusRatio_max),
      tmp %>% top_n(3, YNusRatio_max),
      tmp %>% top_n(3, YNsneRatio_max),
      tmp %>% top_n(3, tpstotal_sd)
   ) %>% pull(instance)

   # More instances
   datAll <- read_csv("../statistics.csv") %>%   #"../convert/data/stat.csv"
      filter(coef == "spheredown", rangeC == "[1,1000]" | rangeC == "[1,1000]|[1,100]") %>% #
      mutate(YNsRatio = YNs/YN,
             YNusRatio = 1-YNs/YN,
             YNsneRatio = (YNs-YNse)/YN,
             algConfig = tolower(str_c(nodesel, varsel, OB, sep="|")),
             resultName = str_c(instance, algConfig, sep="_"))
   algConfigsN <- length(unique(datAll$algConfig))
   tmp <- datAll %>%
      group_by(instance) %>%
      summarise(minCpu = min(tpstotal), maxCpu = max(tpstotal)) %>%
      filter(maxCpu < limSec[1] | minCpu > limSec[2]) %>%
      pull(instance)
   datAll <- datAll %>%
      filter(!(instance %in% tmp)) %>%
      mutate(solved = if_else(tpstotal >= limSec[2] | solved == 0, 0, 1)) %>%
      group_by(instance) %>%
      filter(n() == algConfigsN) %>%
      ungroup() %>%
      mutate(tpstotal = if_else(tpstotal >= limSec[2], limSec[2], tpstotal))
   tmp <- datAll %>%
      group_by(instance) %>% filter(coef == "spheredown") %>%
      summarise_at(vars(contains(c("YN", "total", "solved"))), list(mean = mean, sd = sd, max = max), na.rm = TRUE)
   inst <- c(
      inst,
      bind_rows(
         tmp %>% top_n(-3, YN_max),
         tmp %>% filter(solved_max == 1) %>% top_n(3, YN_max),
         tmp %>% filter(solved_max < 1) %>% top_n(3, YN_max),
         tmp %>% top_n(-3, YNusRatio_max),
         tmp %>% top_n(3, YNusRatio_max),
         tmp %>% top_n(3, YNsneRatio_max),
         tmp %>% top_n(3, tpstotal_sd)) %>%
      pull(instance))
   tmp <- datAll %>%
      group_by(instance) %>% filter(coef == "sphereup") %>%
      summarise_at(vars(contains(c("YN", "total", "solved"))), list(mean = mean, sd = sd, max = max), na.rm = TRUE)
   inst <- c(
      inst,
      bind_rows(
         tmp %>% top_n(-3, YN_max),
         tmp %>% filter(solved_max == 1) %>% top_n(3, YN_max),
         tmp %>% filter(solved_max < 1) %>% top_n(3, YN_max),
         tmp %>% top_n(-3, YNusRatio_max),
         tmp %>% top_n(3, YNusRatio_max),
         tmp %>% top_n(3, YNsneRatio_max),
         tmp %>% top_n(3, tpstotal_sd)) %>%
         pull(instance))

   ## More instances
   tmp <- read_csv("../statistics.csv") %>%
      dplyr::filter(grepl("_1_2", .data$instance)) %>%
      distinct(instance) %>%
      pull(instance)
   inst <- c(inst, tmp)

   # Generate instance reports
   inst <- unique(inst)
   reset <- FALSE
   for(j in 1:length(inst)){
     i <- inst[j]
     cat("File", i, " (", j, "/", length(inst), ")\n")
     if (file.exists(paste0("../../docs/instances/", i, ".html")) & !reset) next
     try(rmarkdown::render("instance.Rmd", output_file = paste0(i, ".html"),
                       output_dir = "../../docs/instances", quiet = T, envir = new.env(),
            params=list(new_title=paste("Results for instance", i) , currentInstance = i) ))
   }
}

## Generate result report
rmarkdown::render("report.Rmd", output_file="report.html", output_dir = "../../docs/")
rmarkdown::render("report_paper.Rmd", output_file="report_paper.html", output_dir = "../../docs/")

setwd(oldDir)
## That's it :-)
