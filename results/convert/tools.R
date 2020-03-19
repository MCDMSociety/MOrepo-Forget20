## Tools for converting result output to the right format
## Note set working dir to source file location

remotes::install_github("MCDMSociety/MOrepo/misc/R/MOrepoTools")
library(MOrepoTools)
library(tidyverse)
dat <- read_csv("data/stat.csv")

for (i in 1:nrow(dat)) {
   # must load the correct results here
   pts <- data.frame(z1 = c(27, 30, 31, 34, 42, 43, 49, 51), z2 = c(56, 53, 36, 33, 30, 25, 23, 9),
      type = c('se', 'us', 'se', 'us', 'us', 'us', 'us', 'se'))

   createResultFile(
      instanceName = dat$instance[i],
      contributionName = "Forget20",
      objectives = dat$p[i],
      objectiveType = rep("int", dat$p[i]),
      direction = rep("min", dat$p[i]),  # are we always using min?
      cpu = list(sec = 3, machineSpec = "Intel ...")
      points = pts,
      card = dat$YN[i],
      suppCard = NA,
      extCard = NA,
      comments = "",
      misc = list(instanceStat = list(a=2), treeStat = list(b=3)),  # we add all other thing here
      optimal = TRUE
   )
}


