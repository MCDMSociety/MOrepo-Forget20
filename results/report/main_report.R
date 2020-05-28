#### Main file for report generation
loadPackages <- function(packages) {
   newP <- packages[!(packages %in% installed.packages()[,"Package"])]
   if(length(newP)) install.packages(newP, repos = "http://cran.rstudio.com/")
   lapply(packages, library, character.only = TRUE)
   invisible(NULL)
}
loadPackages(c("tidyverse", "rmarkdown"))
# options(rgl.useNULL=TRUE)

oldDir <- setwd("./results/report")
## Some special instances
tmp <- read_csv("../statistics.csv") %>%
   mutate(YNsRatio = YNs/YN, YNusRatio = 1-YNs/YN, YNsneRatio = (YNs-YNse)/YN) %>%
   group_by(instance) %>%
   summarise_at(vars(contains(c("YN", "total"))), list(mean = mean, sd = sd, max = max), na.rm = TRUE)
inst <- bind_rows(
   tmp %>% top_n(-3, YN_mean),
   tmp %>% top_n(-3, YNusRatio_mean),
   tmp %>% top_n(3, YNusRatio_mean),
   tmp %>% top_n(3, YNsneRatio_mean),
   tmp %>% top_n(3, tpstotal_sd),
   tmp %>% top_n(3, YN_mean)
) %>% pull(instance)
tmp <- read_csv("../statistics.csv") %>%
   dplyr::filter(grepl("1_2", .data$instance)) %>%
   distinct(instance) %>%
   pull(instance)
inst <- c(inst, tmp)
inst <- unique(inst)
# Generate instance reports
reset <- TRUE
for(i in inst){
  cat("File", i, "\n")
  if (file.exists(paste0("instances/", i, ".html")) & !reset) next
  try(rmarkdown::render("instance.Rmd", output_file = paste0(i, ".html"),
                    output_dir = "instances", quiet = T, #envir = new.env(),
         params=list(new_title=paste("Results for instance", i) , currentInstance = i) ))
}
setwd(oldDir)

## Generate result report
rmarkdown::render("results/report/report.Rmd", output_file="report.html")

## That's it :-)
