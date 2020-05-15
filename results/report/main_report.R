## Main file for report generation

## Generate result file for each instance

# D <- read_csv("data/stat.csv")
# inst <- filter(D, solved == 1,n!=100,n!=121)
# inst <- distinct(inst, instance)
# inst
#
# for(i in inst[[1]]){
#   print(i)
#   rmarkdown::render("instance.Rmd", output_file=paste0("reports/instances/res_", i, ".html"),
#          params=list(new_title=paste("Results for instance", i) , currentInstance = i) )
# }
#
# i <- "Forget20-AP_10_3_1-10_2box_1_1"
# rmarkdown::render("instance.Rmd", output_file=paste0("res_", i, ".html"),
#                   params=list(new_title=paste("Results for instance", i) , currentInstance = i) )


## Generate result report
rmarkdown::render("results/report/report.Rmd", output_file="report.html")

## That's it :-)







#
# # Objective branching CPU times
#
# Here are tested different version of objective branching with the best configuration found in the preliminary tests.
#
# I was thinking of introducing some plots showing the computational time of the different procedures of the algorithm to show what is expensive. Should I do it for each combination coef/range, or is it too much plots and only do it for the best configuration of objective branching ?
#
#   Also, when objective branching is used, infeasibility is the main reason of fathoming while it is dominance when no objective branching is used. Furthermore, from what I observed so far, fathoming by infeasibility is much faster than fathoming by dominance, which could be a reason why it works well. I would like to show that, but I haven't found a satisfying way to do it yet.
#
# ## Random coefficient generation
#
# ### Range : [1,10]
#
# ```{r,echo=FALSE}
# temp <- filter(datOB,coef == "random",rangemin == 1,rangemax == 10)
# tab <- filter(temp,solved == 1)
# tab <- temp %>%
#   group_by(pb,n,OB) %>%
#     summarize(avg = mean(tpstotal))
#
# pivot_wider(tab,names_from = OB, values_from = avg)
#
# st <- seq(0,4,by=0.5)
# val1 <- rep(0,length(st))
# t <- filter(temp, OB=="None")
# for (i in 1:length(st)) {
#   bidouille <- count(t,tpstotal <= st[i])
#   bidouille <- filter(bidouille,bidouille[1]!=FALSE)
#   if (count(bidouille) == 0) {
#     numer <- 0
#   }
#   else{
#     numer <- bidouille[[1,2]]
#   }
#   val1[i] <- 100*numer/count(t)[[1]]
# }
# val2 <- rep(0,length(st))
# t <- filter(temp, OB=="exact")
# for (i in 1:length(st)) {
#   bidouille <- count(t,tpstotal <= st[i])
#   bidouille <- filter(bidouille,bidouille[1]!=FALSE)
#   if (count(bidouille) == 0) {
#     numer <- 0
#   }
#   else{
#     numer <- bidouille[[1,2]]
#   }
#   val2[i] <- 100*numer/count(t)[[1]]
# }
# val3 <- rep(0,length(st))
# t <- filter(temp, OB=="cone")
# for (i in 1:length(st)) {
#   bidouille <- count(t,tpstotal <= st[i])
#   bidouille <- filter(bidouille,bidouille[1]!=FALSE)
#   if (count(bidouille) == 0) {
#     numer <- 0
#   }
#   else{
#     numer <- bidouille[[1,2]]
#   }
#   val3[i] <- 100*numer/count(t)[[1]]
# }
# pl <- tibble( step=st , perfBasic=val1, perfOB=val2, perfCone=val3)
# pl %>% ggplot( aes(x=step)) + geom_line(aes(y=perfBasic,colour="none")) + geom_line(aes(y=perfOB,colour="exact")) + geom_line(aes(y=perfCone,colour="cone")) + xlab("time (sec)") + ylab("% of solved instances") + ggtitle("Performance profile of objective branching")
#
# ```
#
# #### Knapsack
#
# Proportion of unsolved instances for each objective branching strategy in function of the number of variables for tri-objective Knapsack problems.
#
# ```{r,echo=FALSE}
# # unsolved stat
#
# t <- filter(temp,pb=="KP") %>% group_by(OB,n) %>% count(solved==1)
# t <- mutate(t,norm = 100*nn/3)
# t %>%
#   ggplot(aes(x=n, y=norm, group=OB, color=OB)) + geom_line() + xlab("number of variables") + ylab("% of instances solved") + ggtitle("Percentage of tri-objective Knapsack problem instances solved") + ylim(0,100)
# ```
#
# Relative CPU time of the main components of the branch and bound in function of the number of variable for the branch and bound without objective branching. The category "Others" include variable selection, node selection, creation of nodes and other implementation related details.
#
# ```{r,echo=FALSE}
# # time repartition stat
#
# timerep <- filter(temp,pb=="KP",OB=="None") %>%
#   group_by(OB,n) %>%
#     summarize(additional_domi = 100, SLUB = mean(100-pcttpsdomiLUB), LB = mean(100-pcttpsdomiLUB-pcttpsSLUB), domi = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB), others = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB-pcttpsdomi) )
#
# timerep %>% ggplot(aes(x=n)) + geom_area( aes(y = additional_domi , fill = "Additional dominance tests for LUBs")) + geom_area( aes(y = SLUB , fill = "Computation of SLUBs")) + geom_area( aes(y = LB , fill = "LB set")) + geom_area( aes(y = domi , fill = "Dominance test")) + geom_area(aes(y = others , fill = "Others")) + xlab("Number of variables") + ylab("% of computational time") + ggtitle("No objective branching")
# ```
#
# Relative CPU time of the main components of the branch and bound in function of the number of variable for the branch and bound with exact objective branching. The category "Others" include variable selection, node selection, creation of nodes and other implementation related details.
#
# ```{r,echo=FALSE}
# timerep <- filter(temp,pb=="KP",OB=="exact") %>%
#   group_by(OB,n) %>%
#     summarize(additional_domi = 100, SLUB = mean(100-pcttpsdomiLUB), LB = mean(100-pcttpsdomiLUB-pcttpsSLUB), domi = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB), others = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB-pcttpsdomi) )
#
# timerep %>% ggplot(aes(x=n)) + geom_area( aes(y = additional_domi , fill = "Additional dominance tests for LUBs")) + geom_area( aes(y = SLUB , fill = "Computation of SLUBs")) + geom_area( aes(y = LB , fill = "LB set")) + geom_area( aes(y = domi , fill = "Dominance test")) + geom_area(aes(y = others , fill = "Others")) + xlab("Number of variables") + ylab("% of computational time") + ggtitle("Exact objective branching")
# ```
#
# Relative CPU time of the main components of the branch and bound in function of the number of variable for the branch and bound with the conic objective branching. The category "Others" include variable selection, node selection, creation of nodes and other implementation related details.
#
# ```{r,echo=FALSE}
# timerep <- filter(temp,pb=="KP",OB=="cone") %>%
#   group_by(OB,n) %>%
#     summarize(additional_domi = 100, SLUB = mean(100-pcttpsdomiLUB), LB = mean(100-pcttpsdomiLUB-pcttpsSLUB), domi = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB), others = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB-pcttpsdomi) )
#
# timerep %>% ggplot(aes(x=n)) + geom_area( aes(y = additional_domi , fill = "Additional dominance tests for LUBs")) + geom_area( aes(y = SLUB , fill = "Computation of SLUBs")) + geom_area( aes(y = LB , fill = "LB set")) + geom_area( aes(y = domi , fill = "Dominance test")) + geom_area(aes(y = others , fill = "Others")) + xlab("Number of variables") + ylab("% of computational time") + ggtitle("Cone objective branching")
# ```
#
# #### Assignment
#
# Proportion of unsolved instances for each objective branching strategy in function of the number of variables for tri-objective Assignment problems.
#
# ```{r,echo=FALSE}
# t <- filter(temp,pb=="AS") %>% group_by(OB,n) %>% count(solved==1)
# t <- mutate(t,norm = 100*nn/3)
# t %>%
#   ggplot(aes(x=n, y=norm, group=OB, color=OB)) + geom_line() + xlab("number of variables") + ylab("number of instances solved") + ggtitle("Percentage of tri-objective Assignment problem instances solved") + ylim(0,100)
# ```
#
# Relative CPU time of the main components of the branch and bound in function of the number of variable for the branch and bound without objective branching. The category "Others" include variable selection, node selection, creation of nodes and other implementation related details.
#
# ```{r,echo=FALSE}
# # time repartition stat
#
# timerep <- filter(temp,pb=="AS",OB=="None") %>%
#   group_by(OB,n) %>%
#     summarize(additional_domi = 100, SLUB = mean(100-pcttpsdomiLUB), LB = mean(100-pcttpsdomiLUB-pcttpsSLUB), domi = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB), others = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB-pcttpsdomi) )
#
# timerep %>% ggplot(aes(x=n)) + geom_area( aes(y = additional_domi , fill = "Additional dominance tests for LUBs")) + geom_area( aes(y = SLUB , fill = "Computation of SLUBs")) + geom_area( aes(y = LB , fill = "LB set")) + geom_area( aes(y = domi , fill = "Dominance test")) + geom_area(aes(y = others , fill = "Others")) + xlab("Number of variables") + ylab("% of computational time") + ggtitle("No objective branching")
# ```
#
# Relative CPU time of the main components of the branch and bound in function of the number of variable for the branch and bound with exact objective branching. The category "Others" include variable selection, node selection, creation of nodes and other implementation related details.
#
# ```{r,echo=FALSE}
# timerep <- filter(temp,pb=="AS",OB=="exact") %>%
#   group_by(OB,n) %>%
#     summarize(additional_domi = 100, SLUB = mean(100-pcttpsdomiLUB), LB = mean(100-pcttpsdomiLUB-pcttpsSLUB), domi = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB), others = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB-pcttpsdomi) )
#
# timerep %>% ggplot(aes(x=n)) + geom_area( aes(y = additional_domi , fill = "Additional dominance tests for LUBs")) + geom_area( aes(y = SLUB , fill = "Computation of SLUBs")) + geom_area( aes(y = LB , fill = "LB set")) + geom_area( aes(y = domi , fill = "Dominance test")) + geom_area(aes(y = others , fill = "Others")) + xlab("Number of variables") + ylab("% of computational time") + ggtitle("Exact objective branching")
# ```
#
# Relative CPU time of the main components of the branch and bound in function of the number of variable for the branch and bound with the conic objective branching. The category "Others" include variable selection, node selection, creation of nodes and other implementation related details.
#
# ```{r,echo=FALSE}
# timerep <- filter(temp,pb=="AS",OB=="cone") %>%
#   group_by(OB,n) %>%
#     summarize(additional_domi = 100, SLUB = mean(100-pcttpsdomiLUB), LB = mean(100-pcttpsdomiLUB-pcttpsSLUB), domi = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB), others = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB-pcttpsdomi) )
#
# timerep %>% ggplot(aes(x=n)) + geom_area( aes(y = additional_domi , fill = "Additional dominance tests for LUBs")) + geom_area( aes(y = SLUB , fill = "Computation of SLUBs")) + geom_area( aes(y = LB , fill = "LB set")) + geom_area( aes(y = domi , fill = "Dominance test")) + geom_area(aes(y = others , fill = "Others")) + xlab("Number of variables") + ylab("% of computational time") + ggtitle("Cone objective branching")
# ```
#
# #### Facility location easy
#
# Proportion of unsolved instances for each objective branching strategy in function of the number of variables for tri-objective Assignment problems.
#
# ```{r,echo=FALSE}
# t <- filter(temp,pb=="FLe") %>% group_by(OB,n) %>% count(solved==1)
# t <- mutate(t,norm = 100*nn/3)
# t %>%
#   ggplot(aes(x=n, y=norm, group=OB, color=OB)) + geom_line() + xlab("number of variables") + ylab("number of instances solved") + ggtitle("Percentage of tri-objective Assignment problem instances solved") + ylim(0,100)
# ```
#
# Relative CPU time of the main components of the branch and bound in function of the number of variable for the branch and bound without objective branching. The category "Others" include variable selection, node selection, creation of nodes and other implementation related details.
#
# ```{r,echo=FALSE}
# # time repartition stat
#
# timerep <- filter(temp,pb=="FLe",OB=="None") %>%
#   group_by(OB,n) %>%
#     summarize(additional_domi = 100, SLUB = mean(100-pcttpsdomiLUB), LB = mean(100-pcttpsdomiLUB-pcttpsSLUB), domi = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB), others = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB-pcttpsdomi) )
#
# timerep %>% ggplot(aes(x=n)) + geom_area( aes(y = additional_domi , fill = "Additional dominance tests for LUBs")) + geom_area( aes(y = SLUB , fill = "Computation of SLUBs")) + geom_area( aes(y = LB , fill = "LB set")) + geom_area( aes(y = domi , fill = "Dominance test")) + geom_area(aes(y = others , fill = "Others")) + xlab("Number of variables") + ylab("% of computational time") + ggtitle("No objective branching")
# ```
#
# Relative CPU time of the main components of the branch and bound in function of the number of variable for the branch and bound with exact objective branching. The category "Others" include variable selection, node selection, creation of nodes and other implementation related details.
#
# ```{r,echo=FALSE}
# timerep <- filter(temp,pb=="FLe",OB=="exact") %>%
#   group_by(OB,n) %>%
#     summarize(additional_domi = 100, SLUB = mean(100-pcttpsdomiLUB), LB = mean(100-pcttpsdomiLUB-pcttpsSLUB), domi = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB), others = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB-pcttpsdomi) )
#
# timerep %>% ggplot(aes(x=n)) + geom_area( aes(y = additional_domi , fill = "Additional dominance tests for LUBs")) + geom_area( aes(y = SLUB , fill = "Computation of SLUBs")) + geom_area( aes(y = LB , fill = "LB set")) + geom_area( aes(y = domi , fill = "Dominance test")) + geom_area(aes(y = others , fill = "Others")) + xlab("Number of variables") + ylab("% of computational time") + ggtitle("Exact objective branching")
# ```
#
# Relative CPU time of the main components of the branch and bound in function of the number of variable for the branch and bound with the conic objective branching. The category "Others" include variable selection, node selection, creation of nodes and other implementation related details.
#
# ```{r,echo=FALSE}
# timerep <- filter(temp,pb=="FLe",OB=="cone") %>%
#   group_by(OB,n) %>%
#     summarize(additional_domi = 100, SLUB = mean(100-pcttpsdomiLUB), LB = mean(100-pcttpsdomiLUB-pcttpsSLUB), domi = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB), others = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB-pcttpsdomi) )
#
# timerep %>% ggplot(aes(x=n)) + geom_area( aes(y = additional_domi , fill = "Additional dominance tests for LUBs")) + geom_area( aes(y = SLUB , fill = "Computation of SLUBs")) + geom_area( aes(y = LB , fill = "LB set")) + geom_area( aes(y = domi , fill = "Dominance test")) + geom_area(aes(y = others , fill = "Others")) + xlab("Number of variables") + ylab("% of computational time") + ggtitle("Cone objective branching")
# ```
#
# #### Facility location hard
#
# Proportion of unsolved instances for each objective branching strategy in function of the number of variables for tri-objective Assignment problems.
#
# ```{r,echo=FALSE}
# t <- filter(temp,pb=="FLh") %>% group_by(OB,n) %>% count(solved==1)
# t <- mutate(t,norm = 100*nn/3)
# t %>%
#   ggplot(aes(x=n, y=norm, group=OB, color=OB)) + geom_line() + xlab("number of variables") + ylab("number of instances solved") + ggtitle("Percentage of tri-objective Assignment problem instances solved") + ylim(0,100)
# ```
#
# Relative CPU time of the main components of the branch and bound in function of the number of variable for the branch and bound without objective branching. The category "Others" include variable selection, node selection, creation of nodes and other implementation related details.
#
# ```{r,echo=FALSE}
# # time repartition stat
#
# timerep <- filter(temp,pb=="FLh",OB=="None") %>%
#   group_by(OB,n) %>%
#     summarize(additional_domi = 100, SLUB = mean(100-pcttpsdomiLUB), LB = mean(100-pcttpsdomiLUB-pcttpsSLUB), domi = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB), others = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB-pcttpsdomi) )
#
# timerep %>% ggplot(aes(x=n)) + geom_area( aes(y = additional_domi , fill = "Additional dominance tests for LUBs")) + geom_area( aes(y = SLUB , fill = "Computation of SLUBs")) + geom_area( aes(y = LB , fill = "LB set")) + geom_area( aes(y = domi , fill = "Dominance test")) + geom_area(aes(y = others , fill = "Others")) + xlab("Number of variables") + ylab("% of computational time") + ggtitle("No objective branching")
# ```
#
# Relative CPU time of the main components of the branch and bound in function of the number of variable for the branch and bound with exact objective branching. The category "Others" include variable selection, node selection, creation of nodes and other implementation related details.
#
# ```{r,echo=FALSE}
# timerep <- filter(temp,pb=="FLh",OB=="exact") %>%
#   group_by(OB,n) %>%
#     summarize(additional_domi = 100, SLUB = mean(100-pcttpsdomiLUB), LB = mean(100-pcttpsdomiLUB-pcttpsSLUB), domi = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB), others = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB-pcttpsdomi) )
#
# timerep %>% ggplot(aes(x=n)) + geom_area( aes(y = additional_domi , fill = "Additional dominance tests for LUBs")) + geom_area( aes(y = SLUB , fill = "Computation of SLUBs")) + geom_area( aes(y = LB , fill = "LB set")) + geom_area( aes(y = domi , fill = "Dominance test")) + geom_area(aes(y = others , fill = "Others")) + xlab("Number of variables") + ylab("% of computational time") + ggtitle("Exact objective branching")
# ```
#
# Relative CPU time of the main components of the branch and bound in function of the number of variable for the branch and bound with the conic objective branching. The category "Others" include variable selection, node selection, creation of nodes and other implementation related details.
#
# ```{r,echo=FALSE}
# timerep <- filter(temp,pb=="FLh",OB=="cone") %>%
#   group_by(OB,n) %>%
#     summarize(additional_domi = 100, SLUB = mean(100-pcttpsdomiLUB), LB = mean(100-pcttpsdomiLUB-pcttpsSLUB), domi = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB), others = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB-pcttpsdomi) )
#
# timerep %>% ggplot(aes(x=n)) + geom_area( aes(y = additional_domi , fill = "Additional dominance tests for LUBs")) + geom_area( aes(y = SLUB , fill = "Computation of SLUBs")) + geom_area( aes(y = LB , fill = "LB set")) + geom_area( aes(y = domi , fill = "Dominance test")) + geom_area(aes(y = others , fill = "Others")) + xlab("Number of variables") + ylab("% of computational time") + ggtitle("Cone objective branching")
# ```
#
#
# ### Range : [1,1000]
#
# ```{r,echo=FALSE}
# temp <- filter(datOB,coef == "random",rangemin == 1,rangemax == 1000)
# tab <- filter(temp,solved == 1)
# tab <- temp %>%
#   group_by(pb,n,OB) %>%
#     summarize(avg = mean(tpstotal))
#
# pivot_wider(tab,names_from = OB, values_from = avg)
#
# st <- seq(0,4,by=0.5)
# val1 <- rep(0,length(st))
# t <- filter(temp, OB=="None")
# for (i in 1:length(st)) {
#   bidouille <- count(t,tpstotal <= st[i])
#   bidouille <- filter(bidouille,bidouille[1]!=FALSE)
#   if (count(bidouille) == 0) {
#     numer <- 0
#   }
#   else{
#     numer <- bidouille[[1,2]]
#   }
#   val1[i] <- 100*numer/count(t)[[1]]
# }
# val2 <- rep(0,length(st))
# t <- filter(temp, OB=="exact")
# for (i in 1:length(st)) {
#   bidouille <- count(t,tpstotal <= st[i])
#   bidouille <- filter(bidouille,bidouille[1]!=FALSE)
#   if (count(bidouille) == 0) {
#     numer <- 0
#   }
#   else{
#     numer <- bidouille[[1,2]]
#   }
#   val2[i] <- 100*numer/count(t)[[1]]
# }
# val3 <- rep(0,length(st))
# t <- filter(temp, OB=="cone")
# for (i in 1:length(st)) {
#   bidouille <- count(t,tpstotal <= st[i])
#   bidouille <- filter(bidouille,bidouille[1]!=FALSE)
#   if (count(bidouille) == 0) {
#     numer <- 0
#   }
#   else{
#     numer <- bidouille[[1,2]]
#   }
#   val3[i] <- 100*numer/count(t)[[1]]
# }
# pl <- tibble( step=st , perfBasic=val1, perfOB=val2, perfCone=val3)
# pl %>% ggplot( aes(x=step)) + geom_line(aes(y=perfBasic,colour="none")) + geom_line(aes(y=perfOB,colour="exact")) + geom_line(aes(y=perfCone,colour="cone")) + xlab("time (sec)") + ylab("% of solved instances") + ggtitle("Performance profile of objective branching")
#
# ```
#
# #### Knapsack
#
# Proportion of unsolved instances for each objective branching strategy in function of the number of variables for tri-objective Knapsack problems.
#
# ```{r,echo=FALSE}
# # unsolved stat
#
# t <- filter(temp,pb=="KP") %>% group_by(OB,n) %>% count(solved==1)
# t <- mutate(t,norm = 100*nn/3)
# t %>%
#   ggplot(aes(x=n, y=norm, group=OB, color=OB)) + geom_line() + xlab("number of variables") + ylab("% of instances solved") + ggtitle("Percentage of tri-objective Knapsack problem instances solved") + ylim(0,100)
# ```
#
# Relative CPU time of the main components of the branch and bound in function of the number of variable for the branch and bound without objective branching. The category "Others" include variable selection, node selection, creation of nodes and other implementation related details.
#
# ```{r,echo=FALSE}
# # time repartition stat
#
# timerep <- filter(temp,pb=="KP",OB=="None") %>%
#   group_by(OB,n) %>%
#     summarize(additional_domi = 100, SLUB = mean(100-pcttpsdomiLUB), LB = mean(100-pcttpsdomiLUB-pcttpsSLUB), domi = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB), others = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB-pcttpsdomi) )
#
# timerep %>% ggplot(aes(x=n)) + geom_area( aes(y = additional_domi , fill = "Additional dominance tests for LUBs")) + geom_area( aes(y = SLUB , fill = "Computation of SLUBs")) + geom_area( aes(y = LB , fill = "LB set")) + geom_area( aes(y = domi , fill = "Dominance test")) + geom_area(aes(y = others , fill = "Others")) + xlab("Number of variables") + ylab("% of computational time") + ggtitle("No objective branching")
# ```
#
# Relative CPU time of the main components of the branch and bound in function of the number of variable for the branch and bound with exact objective branching. The category "Others" include variable selection, node selection, creation of nodes and other implementation related details.
#
# ```{r,echo=FALSE}
# timerep <- filter(temp,pb=="KP",OB=="exact") %>%
#   group_by(OB,n) %>%
#     summarize(additional_domi = 100, SLUB = mean(100-pcttpsdomiLUB), LB = mean(100-pcttpsdomiLUB-pcttpsSLUB), domi = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB), others = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB-pcttpsdomi) )
#
# timerep %>% ggplot(aes(x=n)) + geom_area( aes(y = additional_domi , fill = "Additional dominance tests for LUBs")) + geom_area( aes(y = SLUB , fill = "Computation of SLUBs")) + geom_area( aes(y = LB , fill = "LB set")) + geom_area( aes(y = domi , fill = "Dominance test")) + geom_area(aes(y = others , fill = "Others")) + xlab("Number of variables") + ylab("% of computational time") + ggtitle("Exact objective branching")
# ```
#
# Relative CPU time of the main components of the branch and bound in function of the number of variable for the branch and bound with the conic objective branching. The category "Others" include variable selection, node selection, creation of nodes and other implementation related details.
#
# ```{r,echo=FALSE}
# timerep <- filter(temp,pb=="KP",OB=="cone") %>%
#   group_by(OB,n) %>%
#     summarize(additional_domi = 100, SLUB = mean(100-pcttpsdomiLUB), LB = mean(100-pcttpsdomiLUB-pcttpsSLUB), domi = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB), others = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB-pcttpsdomi) )
#
# timerep %>% ggplot(aes(x=n)) + geom_area( aes(y = additional_domi , fill = "Additional dominance tests for LUBs")) + geom_area( aes(y = SLUB , fill = "Computation of SLUBs")) + geom_area( aes(y = LB , fill = "LB set")) + geom_area( aes(y = domi , fill = "Dominance test")) + geom_area(aes(y = others , fill = "Others")) + xlab("Number of variables") + ylab("% of computational time") + ggtitle("Cone objective branching")
# ```
#
# #### Assignment
#
# Proportion of unsolved instances for each objective branching strategy in function of the number of variables for tri-objective Assignment problems.
#
# ```{r,echo=FALSE}
# t <- filter(temp,pb=="AS") %>% group_by(OB,n) %>% count(solved==1)
# t <- mutate(t,norm = 100*nn/3)
# t %>%
#   ggplot(aes(x=n, y=norm, group=OB, color=OB)) + geom_line() + xlab("number of variables") + ylab("number of instances solved") + ggtitle("Percentage of tri-objective Assignment problem instances solved") + ylim(0,100)
# ```
#
# Relative CPU time of the main components of the branch and bound in function of the number of variable for the branch and bound without objective branching. The category "Others" include variable selection, node selection, creation of nodes and other implementation related details.
#
# ```{r,echo=FALSE}
# # time repartition stat
#
# timerep <- filter(temp,pb=="AS",OB=="None") %>%
#   group_by(OB,n) %>%
#     summarize(additional_domi = 100, SLUB = mean(100-pcttpsdomiLUB), LB = mean(100-pcttpsdomiLUB-pcttpsSLUB), domi = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB), others = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB-pcttpsdomi) )
#
# timerep %>% ggplot(aes(x=n)) + geom_area( aes(y = additional_domi , fill = "Additional dominance tests for LUBs")) + geom_area( aes(y = SLUB , fill = "Computation of SLUBs")) + geom_area( aes(y = LB , fill = "LB set")) + geom_area( aes(y = domi , fill = "Dominance test")) + geom_area(aes(y = others , fill = "Others")) + xlab("Number of variables") + ylab("% of computational time") + ggtitle("No objective branching")
# ```
#
# Relative CPU time of the main components of the branch and bound in function of the number of variable for the branch and bound with exact objective branching. The category "Others" include variable selection, node selection, creation of nodes and other implementation related details.
#
# ```{r,echo=FALSE}
# timerep <- filter(temp,pb=="AS",OB=="exact") %>%
#   group_by(OB,n) %>%
#     summarize(additional_domi = 100, SLUB = mean(100-pcttpsdomiLUB), LB = mean(100-pcttpsdomiLUB-pcttpsSLUB), domi = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB), others = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB-pcttpsdomi) )
#
# timerep %>% ggplot(aes(x=n)) + geom_area( aes(y = additional_domi , fill = "Additional dominance tests for LUBs")) + geom_area( aes(y = SLUB , fill = "Computation of SLUBs")) + geom_area( aes(y = LB , fill = "LB set")) + geom_area( aes(y = domi , fill = "Dominance test")) + geom_area(aes(y = others , fill = "Others")) + xlab("Number of variables") + ylab("% of computational time") + ggtitle("Exact objective branching")
# ```
#
# Relative CPU time of the main components of the branch and bound in function of the number of variable for the branch and bound with the conic objective branching. The category "Others" include variable selection, node selection, creation of nodes and other implementation related details.
#
# ```{r,echo=FALSE}
# timerep <- filter(temp,pb=="AS",OB=="cone") %>%
#   group_by(OB,n) %>%
#     summarize(additional_domi = 100, SLUB = mean(100-pcttpsdomiLUB), LB = mean(100-pcttpsdomiLUB-pcttpsSLUB), domi = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB), others = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB-pcttpsdomi) )
#
# timerep %>% ggplot(aes(x=n)) + geom_area( aes(y = additional_domi , fill = "Additional dominance tests for LUBs")) + geom_area( aes(y = SLUB , fill = "Computation of SLUBs")) + geom_area( aes(y = LB , fill = "LB set")) + geom_area( aes(y = domi , fill = "Dominance test")) + geom_area(aes(y = others , fill = "Others")) + xlab("Number of variables") + ylab("% of computational time") + ggtitle("Cone objective branching")
# ```
#
# #### Facility location easy
#
# Proportion of unsolved instances for each objective branching strategy in function of the number of variables for tri-objective Assignment problems.
#
# ```{r,echo=FALSE}
# t <- filter(temp,pb=="FLe") %>% group_by(OB,n) %>% count(solved==1)
# t <- mutate(t,norm = 100*nn/3)
# t %>%
#   ggplot(aes(x=n, y=norm, group=OB, color=OB)) + geom_line() + xlab("number of variables") + ylab("number of instances solved") + ggtitle("Percentage of tri-objective Assignment problem instances solved") + ylim(0,100)
# ```
#
# Relative CPU time of the main components of the branch and bound in function of the number of variable for the branch and bound without objective branching. The category "Others" include variable selection, node selection, creation of nodes and other implementation related details.
#
# ```{r,echo=FALSE}
# # time repartition stat
#
# timerep <- filter(temp,pb=="FLe",OB=="None") %>%
#   group_by(OB,n) %>%
#     summarize(additional_domi = 100, SLUB = mean(100-pcttpsdomiLUB), LB = mean(100-pcttpsdomiLUB-pcttpsSLUB), domi = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB), others = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB-pcttpsdomi) )
#
# timerep %>% ggplot(aes(x=n)) + geom_area( aes(y = additional_domi , fill = "Additional dominance tests for LUBs")) + geom_area( aes(y = SLUB , fill = "Computation of SLUBs")) + geom_area( aes(y = LB , fill = "LB set")) + geom_area( aes(y = domi , fill = "Dominance test")) + geom_area(aes(y = others , fill = "Others")) + xlab("Number of variables") + ylab("% of computational time") + ggtitle("No objective branching")
# ```
#
# Relative CPU time of the main components of the branch and bound in function of the number of variable for the branch and bound with exact objective branching. The category "Others" include variable selection, node selection, creation of nodes and other implementation related details.
#
# ```{r,echo=FALSE}
# timerep <- filter(temp,pb=="FLe",OB=="exact") %>%
#   group_by(OB,n) %>%
#     summarize(additional_domi = 100, SLUB = mean(100-pcttpsdomiLUB), LB = mean(100-pcttpsdomiLUB-pcttpsSLUB), domi = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB), others = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB-pcttpsdomi) )
#
# timerep %>% ggplot(aes(x=n)) + geom_area( aes(y = additional_domi , fill = "Additional dominance tests for LUBs")) + geom_area( aes(y = SLUB , fill = "Computation of SLUBs")) + geom_area( aes(y = LB , fill = "LB set")) + geom_area( aes(y = domi , fill = "Dominance test")) + geom_area(aes(y = others , fill = "Others")) + xlab("Number of variables") + ylab("% of computational time") + ggtitle("Exact objective branching")
# ```
#
# Relative CPU time of the main components of the branch and bound in function of the number of variable for the branch and bound with the conic objective branching. The category "Others" include variable selection, node selection, creation of nodes and other implementation related details.
#
# ```{r,echo=FALSE}
# timerep <- filter(temp,pb=="FLe",OB=="cone") %>%
#   group_by(OB,n) %>%
#     summarize(additional_domi = 100, SLUB = mean(100-pcttpsdomiLUB), LB = mean(100-pcttpsdomiLUB-pcttpsSLUB), domi = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB), others = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB-pcttpsdomi) )
#
# timerep %>% ggplot(aes(x=n)) + geom_area( aes(y = additional_domi , fill = "Additional dominance tests for LUBs")) + geom_area( aes(y = SLUB , fill = "Computation of SLUBs")) + geom_area( aes(y = LB , fill = "LB set")) + geom_area( aes(y = domi , fill = "Dominance test")) + geom_area(aes(y = others , fill = "Others")) + xlab("Number of variables") + ylab("% of computational time") + ggtitle("Cone objective branching")
# ```
#
# #### Facility location hard
#
# Proportion of unsolved instances for each objective branching strategy in function of the number of variables for tri-objective Assignment problems.
#
# ```{r,echo=FALSE}
# t <- filter(temp,pb=="FLh") %>% group_by(OB,n) %>% count(solved==1)
# t <- mutate(t,norm = 100*nn/3)
# t %>%
#   ggplot(aes(x=n, y=norm, group=OB, color=OB)) + geom_line() + xlab("number of variables") + ylab("number of instances solved") + ggtitle("Percentage of tri-objective Assignment problem instances solved") + ylim(0,100)
# ```
#
# Relative CPU time of the main components of the branch and bound in function of the number of variable for the branch and bound without objective branching. The category "Others" include variable selection, node selection, creation of nodes and other implementation related details.
#
# ```{r,echo=FALSE}
# # time repartition stat
#
# timerep <- filter(temp,pb=="FLh",OB=="None") %>%
#   group_by(OB,n) %>%
#     summarize(additional_domi = 100, SLUB = mean(100-pcttpsdomiLUB), LB = mean(100-pcttpsdomiLUB-pcttpsSLUB), domi = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB), others = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB-pcttpsdomi) )
#
# timerep %>% ggplot(aes(x=n)) + geom_area( aes(y = additional_domi , fill = "Additional dominance tests for LUBs")) + geom_area( aes(y = SLUB , fill = "Computation of SLUBs")) + geom_area( aes(y = LB , fill = "LB set")) + geom_area( aes(y = domi , fill = "Dominance test")) + geom_area(aes(y = others , fill = "Others")) + xlab("Number of variables") + ylab("% of computational time") + ggtitle("No objective branching")
# ```
#
# Relative CPU time of the main components of the branch and bound in function of the number of variable for the branch and bound with exact objective branching. The category "Others" include variable selection, node selection, creation of nodes and other implementation related details.
#
# ```{r,echo=FALSE}
# timerep <- filter(temp,pb=="FLh",OB=="exact") %>%
#   group_by(OB,n) %>%
#     summarize(additional_domi = 100, SLUB = mean(100-pcttpsdomiLUB), LB = mean(100-pcttpsdomiLUB-pcttpsSLUB), domi = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB), others = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB-pcttpsdomi) )
#
# timerep %>% ggplot(aes(x=n)) + geom_area( aes(y = additional_domi , fill = "Additional dominance tests for LUBs")) + geom_area( aes(y = SLUB , fill = "Computation of SLUBs")) + geom_area( aes(y = LB , fill = "LB set")) + geom_area( aes(y = domi , fill = "Dominance test")) + geom_area(aes(y = others , fill = "Others")) + xlab("Number of variables") + ylab("% of computational time") + ggtitle("Exact objective branching")
# ```
#
# Relative CPU time of the main components of the branch and bound in function of the number of variable for the branch and bound with the conic objective branching. The category "Others" include variable selection, node selection, creation of nodes and other implementation related details.
#
# ```{r,echo=FALSE}
# timerep <- filter(temp,pb=="FLh",OB=="cone") %>%
#   group_by(OB,n) %>%
#     summarize(additional_domi = 100, SLUB = mean(100-pcttpsdomiLUB), LB = mean(100-pcttpsdomiLUB-pcttpsSLUB), domi = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB), others = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB-pcttpsdomi) )
#
# timerep %>% ggplot(aes(x=n)) + geom_area( aes(y = additional_domi , fill = "Additional dominance tests for LUBs")) + geom_area( aes(y = SLUB , fill = "Computation of SLUBs")) + geom_area( aes(y = LB , fill = "LB set")) + geom_area( aes(y = domi , fill = "Dominance test")) + geom_area(aes(y = others , fill = "Others")) + xlab("Number of variables") + ylab("% of computational time") + ggtitle("Cone objective branching")
# ```
#
#
#
#
#
# ### Range : [1000,2000]
#
# ```{r,echo=FALSE}
# temp <- filter(datOB,coef == "random",rangemin == 1000,rangemax == 2000)
# tab <- filter(temp,solved == 1)
# tab <- temp %>%
#   group_by(pb,n,OB) %>%
#     summarize(avg = mean(tpstotal))
#
# pivot_wider(tab,names_from = OB, values_from = avg)
#
# st <- seq(0,4,by=0.5)
# val1 <- rep(0,length(st))
# t <- filter(temp, OB=="None")
# for (i in 1:length(st)) {
#   bidouille <- count(t,tpstotal <= st[i])
#   bidouille <- filter(bidouille,bidouille[1]!=FALSE)
#   if (count(bidouille) == 0) {
#     numer <- 0
#   }
#   else{
#     numer <- bidouille[[1,2]]
#   }
#   val1[i] <- 100*numer/count(t)[[1]]
# }
# val2 <- rep(0,length(st))
# t <- filter(temp, OB=="exact")
# for (i in 1:length(st)) {
#   bidouille <- count(t,tpstotal <= st[i])
#   bidouille <- filter(bidouille,bidouille[1]!=FALSE)
#   if (count(bidouille) == 0) {
#     numer <- 0
#   }
#   else{
#     numer <- bidouille[[1,2]]
#   }
#   val2[i] <- 100*numer/count(t)[[1]]
# }
# val3 <- rep(0,length(st))
# t <- filter(temp, OB=="cone")
# for (i in 1:length(st)) {
#   bidouille <- count(t,tpstotal <= st[i])
#   bidouille <- filter(bidouille,bidouille[1]!=FALSE)
#   if (count(bidouille) == 0) {
#     numer <- 0
#   }
#   else{
#     numer <- bidouille[[1,2]]
#   }
#   val3[i] <- 100*numer/count(t)[[1]]
# }
# pl <- tibble( step=st , perfBasic=val1, perfOB=val2, perfCone=val3)
# pl %>% ggplot( aes(x=step)) + geom_line(aes(y=perfBasic,colour="none")) + geom_line(aes(y=perfOB,colour="exact")) + geom_line(aes(y=perfCone,colour="cone")) + xlab("time (sec)") + ylab("% of solved instances") + ggtitle("Performance profile of objective branching")
#
# ```
#
# #### Knapsack
#
# Proportion of unsolved instances for each objective branching strategy in function of the number of variables for tri-objective Knapsack problems.
#
# ```{r,echo=FALSE}
# # unsolved stat
#
# t <- filter(temp,pb=="KP") %>% group_by(OB,n) %>% count(solved==1)
# t <- mutate(t,norm = 100*nn/3)
# t %>%
#   ggplot(aes(x=n, y=norm, group=OB, color=OB)) + geom_line() + xlab("number of variables") + ylab("% of instances solved") + ggtitle("Percentage of tri-objective Knapsack problem instances solved") + ylim(0,100)
# ```
#
# Relative CPU time of the main components of the branch and bound in function of the number of variable for the branch and bound without objective branching. The category "Others" include variable selection, node selection, creation of nodes and other implementation related details.
#
# ```{r,echo=FALSE}
# # time repartition stat
#
# timerep <- filter(temp,pb=="KP",OB=="None") %>%
#   group_by(OB,n) %>%
#     summarize(additional_domi = 100, SLUB = mean(100-pcttpsdomiLUB), LB = mean(100-pcttpsdomiLUB-pcttpsSLUB), domi = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB), others = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB-pcttpsdomi) )
#
# timerep %>% ggplot(aes(x=n)) + geom_area( aes(y = additional_domi , fill = "Additional dominance tests for LUBs")) + geom_area( aes(y = SLUB , fill = "Computation of SLUBs")) + geom_area( aes(y = LB , fill = "LB set")) + geom_area( aes(y = domi , fill = "Dominance test")) + geom_area(aes(y = others , fill = "Others")) + xlab("Number of variables") + ylab("% of computational time") + ggtitle("No objective branching")
# ```
#
# Relative CPU time of the main components of the branch and bound in function of the number of variable for the branch and bound with exact objective branching. The category "Others" include variable selection, node selection, creation of nodes and other implementation related details.
#
# ```{r,echo=FALSE}
# timerep <- filter(temp,pb=="KP",OB=="exact") %>%
#   group_by(OB,n) %>%
#     summarize(additional_domi = 100, SLUB = mean(100-pcttpsdomiLUB), LB = mean(100-pcttpsdomiLUB-pcttpsSLUB), domi = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB), others = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB-pcttpsdomi) )
#
# timerep %>% ggplot(aes(x=n)) + geom_area( aes(y = additional_domi , fill = "Additional dominance tests for LUBs")) + geom_area( aes(y = SLUB , fill = "Computation of SLUBs")) + geom_area( aes(y = LB , fill = "LB set")) + geom_area( aes(y = domi , fill = "Dominance test")) + geom_area(aes(y = others , fill = "Others")) + xlab("Number of variables") + ylab("% of computational time") + ggtitle("Exact objective branching")
# ```
#
# Relative CPU time of the main components of the branch and bound in function of the number of variable for the branch and bound with the conic objective branching. The category "Others" include variable selection, node selection, creation of nodes and other implementation related details.
#
# ```{r,echo=FALSE}
# timerep <- filter(temp,pb=="KP",OB=="cone") %>%
#   group_by(OB,n) %>%
#     summarize(additional_domi = 100, SLUB = mean(100-pcttpsdomiLUB), LB = mean(100-pcttpsdomiLUB-pcttpsSLUB), domi = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB), others = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB-pcttpsdomi) )
#
# timerep %>% ggplot(aes(x=n)) + geom_area( aes(y = additional_domi , fill = "Additional dominance tests for LUBs")) + geom_area( aes(y = SLUB , fill = "Computation of SLUBs")) + geom_area( aes(y = LB , fill = "LB set")) + geom_area( aes(y = domi , fill = "Dominance test")) + geom_area(aes(y = others , fill = "Others")) + xlab("Number of variables") + ylab("% of computational time") + ggtitle("Cone objective branching")
# ```
#
# #### Assignment
#
# Proportion of unsolved instances for each objective branching strategy in function of the number of variables for tri-objective Assignment problems.
#
# ```{r,echo=FALSE}
# t <- filter(temp,pb=="AS") %>% group_by(OB,n) %>% count(solved==1)
# t <- mutate(t,norm = 100*nn/3)
# t %>%
#   ggplot(aes(x=n, y=norm, group=OB, color=OB)) + geom_line() + xlab("number of variables") + ylab("number of instances solved") + ggtitle("Percentage of tri-objective Assignment problem instances solved") + ylim(0,100)
# ```
#
# Relative CPU time of the main components of the branch and bound in function of the number of variable for the branch and bound without objective branching. The category "Others" include variable selection, node selection, creation of nodes and other implementation related details.
#
# ```{r,echo=FALSE}
# # time repartition stat
#
# timerep <- filter(temp,pb=="AS",OB=="None") %>%
#   group_by(OB,n) %>%
#     summarize(additional_domi = 100, SLUB = mean(100-pcttpsdomiLUB), LB = mean(100-pcttpsdomiLUB-pcttpsSLUB), domi = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB), others = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB-pcttpsdomi) )
#
# timerep %>% ggplot(aes(x=n)) + geom_area( aes(y = additional_domi , fill = "Additional dominance tests for LUBs")) + geom_area( aes(y = SLUB , fill = "Computation of SLUBs")) + geom_area( aes(y = LB , fill = "LB set")) + geom_area( aes(y = domi , fill = "Dominance test")) + geom_area(aes(y = others , fill = "Others")) + xlab("Number of variables") + ylab("% of computational time") + ggtitle("No objective branching")
# ```
#
# Relative CPU time of the main components of the branch and bound in function of the number of variable for the branch and bound with exact objective branching. The category "Others" include variable selection, node selection, creation of nodes and other implementation related details.
#
# ```{r,echo=FALSE}
# timerep <- filter(temp,pb=="AS",OB=="exact") %>%
#   group_by(OB,n) %>%
#     summarize(additional_domi = 100, SLUB = mean(100-pcttpsdomiLUB), LB = mean(100-pcttpsdomiLUB-pcttpsSLUB), domi = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB), others = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB-pcttpsdomi) )
#
# timerep %>% ggplot(aes(x=n)) + geom_area( aes(y = additional_domi , fill = "Additional dominance tests for LUBs")) + geom_area( aes(y = SLUB , fill = "Computation of SLUBs")) + geom_area( aes(y = LB , fill = "LB set")) + geom_area( aes(y = domi , fill = "Dominance test")) + geom_area(aes(y = others , fill = "Others")) + xlab("Number of variables") + ylab("% of computational time") + ggtitle("Exact objective branching")
# ```
#
# Relative CPU time of the main components of the branch and bound in function of the number of variable for the branch and bound with the conic objective branching. The category "Others" include variable selection, node selection, creation of nodes and other implementation related details.
#
# ```{r,echo=FALSE}
# timerep <- filter(temp,pb=="AS",OB=="cone") %>%
#   group_by(OB,n) %>%
#     summarize(additional_domi = 100, SLUB = mean(100-pcttpsdomiLUB), LB = mean(100-pcttpsdomiLUB-pcttpsSLUB), domi = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB), others = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB-pcttpsdomi) )
#
# timerep %>% ggplot(aes(x=n)) + geom_area( aes(y = additional_domi , fill = "Additional dominance tests for LUBs")) + geom_area( aes(y = SLUB , fill = "Computation of SLUBs")) + geom_area( aes(y = LB , fill = "LB set")) + geom_area( aes(y = domi , fill = "Dominance test")) + geom_area(aes(y = others , fill = "Others")) + xlab("Number of variables") + ylab("% of computational time") + ggtitle("Cone objective branching")
# ```
#
# #### Facility location easy
#
# Proportion of unsolved instances for each objective branching strategy in function of the number of variables for tri-objective Assignment problems.
#
# ```{r,echo=FALSE}
# t <- filter(temp,pb=="FLe") %>% group_by(OB,n) %>% count(solved==1)
# t <- mutate(t,norm = 100*nn/3)
# t %>%
#   ggplot(aes(x=n, y=norm, group=OB, color=OB)) + geom_line() + xlab("number of variables") + ylab("number of instances solved") + ggtitle("Percentage of tri-objective Assignment problem instances solved") + ylim(0,100)
# ```
#
# Relative CPU time of the main components of the branch and bound in function of the number of variable for the branch and bound without objective branching. The category "Others" include variable selection, node selection, creation of nodes and other implementation related details.
#
# ```{r,echo=FALSE}
# # time repartition stat
#
# timerep <- filter(temp,pb=="FLe",OB=="None") %>%
#   group_by(OB,n) %>%
#     summarize(additional_domi = 100, SLUB = mean(100-pcttpsdomiLUB), LB = mean(100-pcttpsdomiLUB-pcttpsSLUB), domi = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB), others = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB-pcttpsdomi) )
#
# timerep %>% ggplot(aes(x=n)) + geom_area( aes(y = additional_domi , fill = "Additional dominance tests for LUBs")) + geom_area( aes(y = SLUB , fill = "Computation of SLUBs")) + geom_area( aes(y = LB , fill = "LB set")) + geom_area( aes(y = domi , fill = "Dominance test")) + geom_area(aes(y = others , fill = "Others")) + xlab("Number of variables") + ylab("% of computational time") + ggtitle("No objective branching")
# ```
#
# Relative CPU time of the main components of the branch and bound in function of the number of variable for the branch and bound with exact objective branching. The category "Others" include variable selection, node selection, creation of nodes and other implementation related details.
#
# ```{r,echo=FALSE}
# timerep <- filter(temp,pb=="FLe",OB=="exact") %>%
#   group_by(OB,n) %>%
#     summarize(additional_domi = 100, SLUB = mean(100-pcttpsdomiLUB), LB = mean(100-pcttpsdomiLUB-pcttpsSLUB), domi = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB), others = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB-pcttpsdomi) )
#
# timerep %>% ggplot(aes(x=n)) + geom_area( aes(y = additional_domi , fill = "Additional dominance tests for LUBs")) + geom_area( aes(y = SLUB , fill = "Computation of SLUBs")) + geom_area( aes(y = LB , fill = "LB set")) + geom_area( aes(y = domi , fill = "Dominance test")) + geom_area(aes(y = others , fill = "Others")) + xlab("Number of variables") + ylab("% of computational time") + ggtitle("Exact objective branching")
# ```
#
# Relative CPU time of the main components of the branch and bound in function of the number of variable for the branch and bound with the conic objective branching. The category "Others" include variable selection, node selection, creation of nodes and other implementation related details.
#
# ```{r,echo=FALSE}
# timerep <- filter(temp,pb=="FLe",OB=="cone") %>%
#   group_by(OB,n) %>%
#     summarize(additional_domi = 100, SLUB = mean(100-pcttpsdomiLUB), LB = mean(100-pcttpsdomiLUB-pcttpsSLUB), domi = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB), others = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB-pcttpsdomi) )
#
# timerep %>% ggplot(aes(x=n)) + geom_area( aes(y = additional_domi , fill = "Additional dominance tests for LUBs")) + geom_area( aes(y = SLUB , fill = "Computation of SLUBs")) + geom_area( aes(y = LB , fill = "LB set")) + geom_area( aes(y = domi , fill = "Dominance test")) + geom_area(aes(y = others , fill = "Others")) + xlab("Number of variables") + ylab("% of computational time") + ggtitle("Cone objective branching")
# ```
#
# #### Facility location hard
#
# Proportion of unsolved instances for each objective branching strategy in function of the number of variables for tri-objective Assignment problems.
#
# ```{r,echo=FALSE}
# t <- filter(temp,pb=="FLh") %>% group_by(OB,n) %>% count(solved==1)
# t <- mutate(t,norm = 100*nn/3)
# t %>%
#   ggplot(aes(x=n, y=norm, group=OB, color=OB)) + geom_line() + xlab("number of variables") + ylab("number of instances solved") + ggtitle("Percentage of tri-objective Assignment problem instances solved") + ylim(0,100)
# ```
#
# Relative CPU time of the main components of the branch and bound in function of the number of variable for the branch and bound without objective branching. The category "Others" include variable selection, node selection, creation of nodes and other implementation related details.
#
# ```{r,echo=FALSE}
# # time repartition stat
#
# timerep <- filter(temp,pb=="FLh",OB=="None") %>%
#   group_by(OB,n) %>%
#     summarize(additional_domi = 100, SLUB = mean(100-pcttpsdomiLUB), LB = mean(100-pcttpsdomiLUB-pcttpsSLUB), domi = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB), others = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB-pcttpsdomi) )
#
# timerep %>% ggplot(aes(x=n)) + geom_area( aes(y = additional_domi , fill = "Additional dominance tests for LUBs")) + geom_area( aes(y = SLUB , fill = "Computation of SLUBs")) + geom_area( aes(y = LB , fill = "LB set")) + geom_area( aes(y = domi , fill = "Dominance test")) + geom_area(aes(y = others , fill = "Others")) + xlab("Number of variables") + ylab("% of computational time") + ggtitle("No objective branching")
# ```
#
# Relative CPU time of the main components of the branch and bound in function of the number of variable for the branch and bound with exact objective branching. The category "Others" include variable selection, node selection, creation of nodes and other implementation related details.
#
# ```{r,echo=FALSE}
# timerep <- filter(temp,pb=="FLh",OB=="exact") %>%
#   group_by(OB,n) %>%
#     summarize(additional_domi = 100, SLUB = mean(100-pcttpsdomiLUB), LB = mean(100-pcttpsdomiLUB-pcttpsSLUB), domi = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB), others = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB-pcttpsdomi) )
#
# timerep %>% ggplot(aes(x=n)) + geom_area( aes(y = additional_domi , fill = "Additional dominance tests for LUBs")) + geom_area( aes(y = SLUB , fill = "Computation of SLUBs")) + geom_area( aes(y = LB , fill = "LB set")) + geom_area( aes(y = domi , fill = "Dominance test")) + geom_area(aes(y = others , fill = "Others")) + xlab("Number of variables") + ylab("% of computational time") + ggtitle("Exact objective branching")
# ```
#
# Relative CPU time of the main components of the branch and bound in function of the number of variable for the branch and bound with the conic objective branching. The category "Others" include variable selection, node selection, creation of nodes and other implementation related details.
#
# ```{r,echo=FALSE}
# timerep <- filter(temp,pb=="FLh",OB=="cone") %>%
#   group_by(OB,n) %>%
#     summarize(additional_domi = 100, SLUB = mean(100-pcttpsdomiLUB), LB = mean(100-pcttpsdomiLUB-pcttpsSLUB), domi = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB), others = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB-pcttpsdomi) )
#
# timerep %>% ggplot(aes(x=n)) + geom_area( aes(y = additional_domi , fill = "Additional dominance tests for LUBs")) + geom_area( aes(y = SLUB , fill = "Computation of SLUBs")) + geom_area( aes(y = LB , fill = "LB set")) + geom_area( aes(y = domi , fill = "Dominance test")) + geom_area(aes(y = others , fill = "Others")) + xlab("Number of variables") + ylab("% of computational time") + ggtitle("Cone objective branching")
# ```
#
#
#
#
#
# ## Lower sphere
#
# ### Range : [1,10]
#
# ```{r,echo=FALSE}
# temp <- filter(datOB,coef == "spheredown",rangemin == 1,rangemax == 10)
# tab <- filter(temp,solved == 1)
# tab <- temp %>%
#   group_by(pb,n,OB) %>%
#     summarize(avg = mean(tpstotal))
#
# pivot_wider(tab,names_from = OB, values_from = avg)
#
# st <- seq(0,4,by=0.5)
# val1 <- rep(0,length(st))
# t <- filter(temp, OB=="None")
# for (i in 1:length(st)) {
#   bidouille <- count(t,tpstotal <= st[i])
#   bidouille <- filter(bidouille,bidouille[1]!=FALSE)
#   if (count(bidouille) == 0) {
#     numer <- 0
#   }
#   else{
#     numer <- bidouille[[1,2]]
#   }
#   val1[i] <- 100*numer/count(t)[[1]]
# }
# val2 <- rep(0,length(st))
# t <- filter(temp, OB=="exact")
# for (i in 1:length(st)) {
#   bidouille <- count(t,tpstotal <= st[i])
#   bidouille <- filter(bidouille,bidouille[1]!=FALSE)
#   if (count(bidouille) == 0) {
#     numer <- 0
#   }
#   else{
#     numer <- bidouille[[1,2]]
#   }
#   val2[i] <- 100*numer/count(t)[[1]]
# }
# val3 <- rep(0,length(st))
# t <- filter(temp, OB=="cone")
# for (i in 1:length(st)) {
#   bidouille <- count(t,tpstotal <= st[i])
#   bidouille <- filter(bidouille,bidouille[1]!=FALSE)
#   if (count(bidouille) == 0) {
#     numer <- 0
#   }
#   else{
#     numer <- bidouille[[1,2]]
#   }
#   val3[i] <- 100*numer/count(t)[[1]]
# }
# pl <- tibble( step=st , perfBasic=val1, perfOB=val2, perfCone=val3)
# pl %>% ggplot( aes(x=step)) + geom_line(aes(y=perfBasic,colour="none")) + geom_line(aes(y=perfOB,colour="exact")) + geom_line(aes(y=perfCone,colour="cone")) + xlab("time (sec)") + ylab("% of solved instances") + ggtitle("Performance profile of objective branching")
#
# ```
#
# #### Knapsack
#
# Proportion of unsolved instances for each objective branching strategy in function of the number of variables for tri-objective Knapsack problems.
#
# ```{r,echo=FALSE}
# # unsolved stat
#
# t <- filter(temp,pb=="KP") %>% group_by(OB,n) %>% count(solved==1)
# t <- mutate(t,norm = 100*nn/3)
# t %>%
#   ggplot(aes(x=n, y=norm, group=OB, color=OB)) + geom_line() + xlab("number of variables") + ylab("% of instances solved") + ggtitle("Percentage of tri-objective Knapsack problem instances solved") + ylim(0,100)
# ```
#
# Relative CPU time of the main components of the branch and bound in function of the number of variable for the branch and bound without objective branching. The category "Others" include variable selection, node selection, creation of nodes and other implementation related details.
#
# ```{r,echo=FALSE}
# # time repartition stat
#
# timerep <- filter(temp,pb=="KP",OB=="None") %>%
#   group_by(OB,n) %>%
#     summarize(additional_domi = 100, SLUB = mean(100-pcttpsdomiLUB), LB = mean(100-pcttpsdomiLUB-pcttpsSLUB), domi = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB), others = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB-pcttpsdomi) )
#
# timerep %>% ggplot(aes(x=n)) + geom_area( aes(y = additional_domi , fill = "Additional dominance tests for LUBs")) + geom_area( aes(y = SLUB , fill = "Computation of SLUBs")) + geom_area( aes(y = LB , fill = "LB set")) + geom_area( aes(y = domi , fill = "Dominance test")) + geom_area(aes(y = others , fill = "Others")) + xlab("Number of variables") + ylab("% of computational time") + ggtitle("No objective branching")
# ```
#
# Relative CPU time of the main components of the branch and bound in function of the number of variable for the branch and bound with exact objective branching. The category "Others" include variable selection, node selection, creation of nodes and other implementation related details.
#
# ```{r,echo=FALSE}
# timerep <- filter(temp,pb=="KP",OB=="exact") %>%
#   group_by(OB,n) %>%
#     summarize(additional_domi = 100, SLUB = mean(100-pcttpsdomiLUB), LB = mean(100-pcttpsdomiLUB-pcttpsSLUB), domi = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB), others = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB-pcttpsdomi) )
#
# timerep %>% ggplot(aes(x=n)) + geom_area( aes(y = additional_domi , fill = "Additional dominance tests for LUBs")) + geom_area( aes(y = SLUB , fill = "Computation of SLUBs")) + geom_area( aes(y = LB , fill = "LB set")) + geom_area( aes(y = domi , fill = "Dominance test")) + geom_area(aes(y = others , fill = "Others")) + xlab("Number of variables") + ylab("% of computational time") + ggtitle("Exact objective branching")
# ```
#
# Relative CPU time of the main components of the branch and bound in function of the number of variable for the branch and bound with the conic objective branching. The category "Others" include variable selection, node selection, creation of nodes and other implementation related details.
#
# ```{r,echo=FALSE}
# timerep <- filter(temp,pb=="KP",OB=="cone") %>%
#   group_by(OB,n) %>%
#     summarize(additional_domi = 100, SLUB = mean(100-pcttpsdomiLUB), LB = mean(100-pcttpsdomiLUB-pcttpsSLUB), domi = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB), others = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB-pcttpsdomi) )
#
# timerep %>% ggplot(aes(x=n)) + geom_area( aes(y = additional_domi , fill = "Additional dominance tests for LUBs")) + geom_area( aes(y = SLUB , fill = "Computation of SLUBs")) + geom_area( aes(y = LB , fill = "LB set")) + geom_area( aes(y = domi , fill = "Dominance test")) + geom_area(aes(y = others , fill = "Others")) + xlab("Number of variables") + ylab("% of computational time") + ggtitle("Cone objective branching")
# ```
#
# #### Assignment
#
# Proportion of unsolved instances for each objective branching strategy in function of the number of variables for tri-objective Assignment problems.
#
# ```{r,echo=FALSE}
# t <- filter(temp,pb=="AS") %>% group_by(OB,n) %>% count(solved==1)
# t <- mutate(t,norm = 100*nn/3)
# t %>%
#   ggplot(aes(x=n, y=norm, group=OB, color=OB)) + geom_line() + xlab("number of variables") + ylab("number of instances solved") + ggtitle("Percentage of tri-objective Assignment problem instances solved") + ylim(0,100)
# ```
#
# Relative CPU time of the main components of the branch and bound in function of the number of variable for the branch and bound without objective branching. The category "Others" include variable selection, node selection, creation of nodes and other implementation related details.
#
# ```{r,echo=FALSE}
# # time repartition stat
#
# timerep <- filter(temp,pb=="AS",OB=="None") %>%
#   group_by(OB,n) %>%
#     summarize(additional_domi = 100, SLUB = mean(100-pcttpsdomiLUB), LB = mean(100-pcttpsdomiLUB-pcttpsSLUB), domi = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB), others = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB-pcttpsdomi) )
#
# timerep %>% ggplot(aes(x=n)) + geom_area( aes(y = additional_domi , fill = "Additional dominance tests for LUBs")) + geom_area( aes(y = SLUB , fill = "Computation of SLUBs")) + geom_area( aes(y = LB , fill = "LB set")) + geom_area( aes(y = domi , fill = "Dominance test")) + geom_area(aes(y = others , fill = "Others")) + xlab("Number of variables") + ylab("% of computational time") + ggtitle("No objective branching")
# ```
#
# Relative CPU time of the main components of the branch and bound in function of the number of variable for the branch and bound with exact objective branching. The category "Others" include variable selection, node selection, creation of nodes and other implementation related details.
#
# ```{r,echo=FALSE}
# timerep <- filter(temp,pb=="AS",OB=="exact") %>%
#   group_by(OB,n) %>%
#     summarize(additional_domi = 100, SLUB = mean(100-pcttpsdomiLUB), LB = mean(100-pcttpsdomiLUB-pcttpsSLUB), domi = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB), others = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB-pcttpsdomi) )
#
# timerep %>% ggplot(aes(x=n)) + geom_area( aes(y = additional_domi , fill = "Additional dominance tests for LUBs")) + geom_area( aes(y = SLUB , fill = "Computation of SLUBs")) + geom_area( aes(y = LB , fill = "LB set")) + geom_area( aes(y = domi , fill = "Dominance test")) + geom_area(aes(y = others , fill = "Others")) + xlab("Number of variables") + ylab("% of computational time") + ggtitle("Exact objective branching")
# ```
#
# Relative CPU time of the main components of the branch and bound in function of the number of variable for the branch and bound with the conic objective branching. The category "Others" include variable selection, node selection, creation of nodes and other implementation related details.
#
# ```{r,echo=FALSE}
# timerep <- filter(temp,pb=="AS",OB=="cone") %>%
#   group_by(OB,n) %>%
#     summarize(additional_domi = 100, SLUB = mean(100-pcttpsdomiLUB), LB = mean(100-pcttpsdomiLUB-pcttpsSLUB), domi = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB), others = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB-pcttpsdomi) )
#
# timerep %>% ggplot(aes(x=n)) + geom_area( aes(y = additional_domi , fill = "Additional dominance tests for LUBs")) + geom_area( aes(y = SLUB , fill = "Computation of SLUBs")) + geom_area( aes(y = LB , fill = "LB set")) + geom_area( aes(y = domi , fill = "Dominance test")) + geom_area(aes(y = others , fill = "Others")) + xlab("Number of variables") + ylab("% of computational time") + ggtitle("Cone objective branching")
# ```
#
# #### Facility location easy
#
# Proportion of unsolved instances for each objective branching strategy in function of the number of variables for tri-objective Assignment problems.
#
# ```{r,echo=FALSE}
# t <- filter(temp,pb=="FLe") %>% group_by(OB,n) %>% count(solved==1)
# t <- mutate(t,norm = 100*nn/3)
# t %>%
#   ggplot(aes(x=n, y=norm, group=OB, color=OB)) + geom_line() + xlab("number of variables") + ylab("number of instances solved") + ggtitle("Percentage of tri-objective Assignment problem instances solved") + ylim(0,100)
# ```
#
# Relative CPU time of the main components of the branch and bound in function of the number of variable for the branch and bound without objective branching. The category "Others" include variable selection, node selection, creation of nodes and other implementation related details.
#
# ```{r,echo=FALSE}
# # time repartition stat
#
# timerep <- filter(temp,pb=="FLe",OB=="None") %>%
#   group_by(OB,n) %>%
#     summarize(additional_domi = 100, SLUB = mean(100-pcttpsdomiLUB), LB = mean(100-pcttpsdomiLUB-pcttpsSLUB), domi = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB), others = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB-pcttpsdomi) )
#
# timerep %>% ggplot(aes(x=n)) + geom_area( aes(y = additional_domi , fill = "Additional dominance tests for LUBs")) + geom_area( aes(y = SLUB , fill = "Computation of SLUBs")) + geom_area( aes(y = LB , fill = "LB set")) + geom_area( aes(y = domi , fill = "Dominance test")) + geom_area(aes(y = others , fill = "Others")) + xlab("Number of variables") + ylab("% of computational time") + ggtitle("No objective branching")
# ```
#
# Relative CPU time of the main components of the branch and bound in function of the number of variable for the branch and bound with exact objective branching. The category "Others" include variable selection, node selection, creation of nodes and other implementation related details.
#
# ```{r,echo=FALSE}
# timerep <- filter(temp,pb=="FLe",OB=="exact") %>%
#   group_by(OB,n) %>%
#     summarize(additional_domi = 100, SLUB = mean(100-pcttpsdomiLUB), LB = mean(100-pcttpsdomiLUB-pcttpsSLUB), domi = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB), others = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB-pcttpsdomi) )
#
# timerep %>% ggplot(aes(x=n)) + geom_area( aes(y = additional_domi , fill = "Additional dominance tests for LUBs")) + geom_area( aes(y = SLUB , fill = "Computation of SLUBs")) + geom_area( aes(y = LB , fill = "LB set")) + geom_area( aes(y = domi , fill = "Dominance test")) + geom_area(aes(y = others , fill = "Others")) + xlab("Number of variables") + ylab("% of computational time") + ggtitle("Exact objective branching")
# ```
#
# Relative CPU time of the main components of the branch and bound in function of the number of variable for the branch and bound with the conic objective branching. The category "Others" include variable selection, node selection, creation of nodes and other implementation related details.
#
# ```{r,echo=FALSE}
# timerep <- filter(temp,pb=="FLe",OB=="cone") %>%
#   group_by(OB,n) %>%
#     summarize(additional_domi = 100, SLUB = mean(100-pcttpsdomiLUB), LB = mean(100-pcttpsdomiLUB-pcttpsSLUB), domi = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB), others = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB-pcttpsdomi) )
#
# timerep %>% ggplot(aes(x=n)) + geom_area( aes(y = additional_domi , fill = "Additional dominance tests for LUBs")) + geom_area( aes(y = SLUB , fill = "Computation of SLUBs")) + geom_area( aes(y = LB , fill = "LB set")) + geom_area( aes(y = domi , fill = "Dominance test")) + geom_area(aes(y = others , fill = "Others")) + xlab("Number of variables") + ylab("% of computational time") + ggtitle("Cone objective branching")
# ```
#
# #### Facility location hard
#
# Proportion of unsolved instances for each objective branching strategy in function of the number of variables for tri-objective Assignment problems.
#
# ```{r,echo=FALSE}
# t <- filter(temp,pb=="FLh") %>% group_by(OB,n) %>% count(solved==1)
# t <- mutate(t,norm = 100*nn/3)
# t %>%
#   ggplot(aes(x=n, y=norm, group=OB, color=OB)) + geom_line() + xlab("number of variables") + ylab("number of instances solved") + ggtitle("Percentage of tri-objective Assignment problem instances solved") + ylim(0,100)
# ```
#
# Relative CPU time of the main components of the branch and bound in function of the number of variable for the branch and bound without objective branching. The category "Others" include variable selection, node selection, creation of nodes and other implementation related details.
#
# ```{r,echo=FALSE}
# # time repartition stat
#
# timerep <- filter(temp,pb=="FLh",OB=="None") %>%
#   group_by(OB,n) %>%
#     summarize(additional_domi = 100, SLUB = mean(100-pcttpsdomiLUB), LB = mean(100-pcttpsdomiLUB-pcttpsSLUB), domi = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB), others = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB-pcttpsdomi) )
#
# timerep %>% ggplot(aes(x=n)) + geom_area( aes(y = additional_domi , fill = "Additional dominance tests for LUBs")) + geom_area( aes(y = SLUB , fill = "Computation of SLUBs")) + geom_area( aes(y = LB , fill = "LB set")) + geom_area( aes(y = domi , fill = "Dominance test")) + geom_area(aes(y = others , fill = "Others")) + xlab("Number of variables") + ylab("% of computational time") + ggtitle("No objective branching")
# ```
#
# Relative CPU time of the main components of the branch and bound in function of the number of variable for the branch and bound with exact objective branching. The category "Others" include variable selection, node selection, creation of nodes and other implementation related details.
#
# ```{r,echo=FALSE}
# timerep <- filter(temp,pb=="FLh",OB=="exact") %>%
#   group_by(OB,n) %>%
#     summarize(additional_domi = 100, SLUB = mean(100-pcttpsdomiLUB), LB = mean(100-pcttpsdomiLUB-pcttpsSLUB), domi = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB), others = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB-pcttpsdomi) )
#
# timerep %>% ggplot(aes(x=n)) + geom_area( aes(y = additional_domi , fill = "Additional dominance tests for LUBs")) + geom_area( aes(y = SLUB , fill = "Computation of SLUBs")) + geom_area( aes(y = LB , fill = "LB set")) + geom_area( aes(y = domi , fill = "Dominance test")) + geom_area(aes(y = others , fill = "Others")) + xlab("Number of variables") + ylab("% of computational time") + ggtitle("Exact objective branching")
# ```
#
# Relative CPU time of the main components of the branch and bound in function of the number of variable for the branch and bound with the conic objective branching. The category "Others" include variable selection, node selection, creation of nodes and other implementation related details.
#
# ```{r,echo=FALSE}
# timerep <- filter(temp,pb=="FLh",OB=="cone") %>%
#   group_by(OB,n) %>%
#     summarize(additional_domi = 100, SLUB = mean(100-pcttpsdomiLUB), LB = mean(100-pcttpsdomiLUB-pcttpsSLUB), domi = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB), others = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB-pcttpsdomi) )
#
# timerep %>% ggplot(aes(x=n)) + geom_area( aes(y = additional_domi , fill = "Additional dominance tests for LUBs")) + geom_area( aes(y = SLUB , fill = "Computation of SLUBs")) + geom_area( aes(y = LB , fill = "LB set")) + geom_area( aes(y = domi , fill = "Dominance test")) + geom_area(aes(y = others , fill = "Others")) + xlab("Number of variables") + ylab("% of computational time") + ggtitle("Cone objective branching")
# ```
#
#
# ### Range : [1,1000]
#
# ```{r,echo=FALSE}
# temp <- filter(datOB,coef == "spheredown",rangemin == 1,rangemax == 1000)
# tab <- filter(temp,solved == 1)
# tab <- temp %>%
#   group_by(pb,n,OB) %>%
#     summarize(avg = mean(tpstotal))
#
# pivot_wider(tab,names_from = OB, values_from = avg)
#
# st <- seq(0,4,by=0.5)
# val1 <- rep(0,length(st))
# t <- filter(temp, OB=="None")
# for (i in 1:length(st)) {
#   bidouille <- count(t,tpstotal <= st[i])
#   bidouille <- filter(bidouille,bidouille[1]!=FALSE)
#   if (count(bidouille) == 0) {
#     numer <- 0
#   }
#   else{
#     numer <- bidouille[[1,2]]
#   }
#   val1[i] <- 100*numer/count(t)[[1]]
# }
# val2 <- rep(0,length(st))
# t <- filter(temp, OB=="exact")
# for (i in 1:length(st)) {
#   bidouille <- count(t,tpstotal <= st[i])
#   bidouille <- filter(bidouille,bidouille[1]!=FALSE)
#   if (count(bidouille) == 0) {
#     numer <- 0
#   }
#   else{
#     numer <- bidouille[[1,2]]
#   }
#   val2[i] <- 100*numer/count(t)[[1]]
# }
# val3 <- rep(0,length(st))
# t <- filter(temp, OB=="cone")
# for (i in 1:length(st)) {
#   bidouille <- count(t,tpstotal <= st[i])
#   bidouille <- filter(bidouille,bidouille[1]!=FALSE)
#   if (count(bidouille) == 0) {
#     numer <- 0
#   }
#   else{
#     numer <- bidouille[[1,2]]
#   }
#   val3[i] <- 100*numer/count(t)[[1]]
# }
# pl <- tibble( step=st , perfBasic=val1, perfOB=val2, perfCone=val3)
# pl %>% ggplot( aes(x=step)) + geom_line(aes(y=perfBasic,colour="none")) + geom_line(aes(y=perfOB,colour="exact")) + geom_line(aes(y=perfCone,colour="cone")) + xlab("time (sec)") + ylab("% of solved instances") + ggtitle("Performance profile of objective branching")
#
# ```
#
# #### Knapsack
#
# Proportion of unsolved instances for each objective branching strategy in function of the number of variables for tri-objective Knapsack problems.
#
# ```{r,echo=FALSE}
# # unsolved stat
#
# t <- filter(temp,pb=="KP") %>% group_by(OB,n) %>% count(solved==1)
# t <- mutate(t,norm = 100*nn/3)
# t %>%
#   ggplot(aes(x=n, y=norm, group=OB, color=OB)) + geom_line() + xlab("number of variables") + ylab("% of instances solved") + ggtitle("Percentage of tri-objective Knapsack problem instances solved") + ylim(0,100)
# ```
#
# Relative CPU time of the main components of the branch and bound in function of the number of variable for the branch and bound without objective branching. The category "Others" include variable selection, node selection, creation of nodes and other implementation related details.
#
# ```{r,echo=FALSE}
# # time repartition stat
#
# timerep <- filter(temp,pb=="KP",OB=="None") %>%
#   group_by(OB,n) %>%
#     summarize(additional_domi = 100, SLUB = mean(100-pcttpsdomiLUB), LB = mean(100-pcttpsdomiLUB-pcttpsSLUB), domi = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB), others = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB-pcttpsdomi) )
#
# timerep %>% ggplot(aes(x=n)) + geom_area( aes(y = additional_domi , fill = "Additional dominance tests for LUBs")) + geom_area( aes(y = SLUB , fill = "Computation of SLUBs")) + geom_area( aes(y = LB , fill = "LB set")) + geom_area( aes(y = domi , fill = "Dominance test")) + geom_area(aes(y = others , fill = "Others")) + xlab("Number of variables") + ylab("% of computational time") + ggtitle("No objective branching")
# ```
#
# Relative CPU time of the main components of the branch and bound in function of the number of variable for the branch and bound with exact objective branching. The category "Others" include variable selection, node selection, creation of nodes and other implementation related details.
#
# ```{r,echo=FALSE}
# timerep <- filter(temp,pb=="KP",OB=="exact") %>%
#   group_by(OB,n) %>%
#     summarize(additional_domi = 100, SLUB = mean(100-pcttpsdomiLUB), LB = mean(100-pcttpsdomiLUB-pcttpsSLUB), domi = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB), others = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB-pcttpsdomi) )
#
# timerep %>% ggplot(aes(x=n)) + geom_area( aes(y = additional_domi , fill = "Additional dominance tests for LUBs")) + geom_area( aes(y = SLUB , fill = "Computation of SLUBs")) + geom_area( aes(y = LB , fill = "LB set")) + geom_area( aes(y = domi , fill = "Dominance test")) + geom_area(aes(y = others , fill = "Others")) + xlab("Number of variables") + ylab("% of computational time") + ggtitle("Exact objective branching")
# ```
#
# Relative CPU time of the main components of the branch and bound in function of the number of variable for the branch and bound with the conic objective branching. The category "Others" include variable selection, node selection, creation of nodes and other implementation related details.
#
# ```{r,echo=FALSE}
# timerep <- filter(temp,pb=="KP",OB=="cone") %>%
#   group_by(OB,n) %>%
#     summarize(additional_domi = 100, SLUB = mean(100-pcttpsdomiLUB), LB = mean(100-pcttpsdomiLUB-pcttpsSLUB), domi = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB), others = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB-pcttpsdomi) )
#
# timerep %>% ggplot(aes(x=n)) + geom_area( aes(y = additional_domi , fill = "Additional dominance tests for LUBs")) + geom_area( aes(y = SLUB , fill = "Computation of SLUBs")) + geom_area( aes(y = LB , fill = "LB set")) + geom_area( aes(y = domi , fill = "Dominance test")) + geom_area(aes(y = others , fill = "Others")) + xlab("Number of variables") + ylab("% of computational time") + ggtitle("Cone objective branching")
# ```
#
# #### Assignment
#
# Proportion of unsolved instances for each objective branching strategy in function of the number of variables for tri-objective Assignment problems.
#
# ```{r,echo=FALSE}
# t <- filter(temp,pb=="AS") %>% group_by(OB,n) %>% count(solved==1)
# t <- mutate(t,norm = 100*nn/3)
# t %>%
#   ggplot(aes(x=n, y=norm, group=OB, color=OB)) + geom_line() + xlab("number of variables") + ylab("number of instances solved") + ggtitle("Percentage of tri-objective Assignment problem instances solved") + ylim(0,100)
# ```
#
# Relative CPU time of the main components of the branch and bound in function of the number of variable for the branch and bound without objective branching. The category "Others" include variable selection, node selection, creation of nodes and other implementation related details.
#
# ```{r,echo=FALSE}
# # time repartition stat
#
# timerep <- filter(temp,pb=="AS",OB=="None") %>%
#   group_by(OB,n) %>%
#     summarize(additional_domi = 100, SLUB = mean(100-pcttpsdomiLUB), LB = mean(100-pcttpsdomiLUB-pcttpsSLUB), domi = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB), others = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB-pcttpsdomi) )
#
# timerep %>% ggplot(aes(x=n)) + geom_area( aes(y = additional_domi , fill = "Additional dominance tests for LUBs")) + geom_area( aes(y = SLUB , fill = "Computation of SLUBs")) + geom_area( aes(y = LB , fill = "LB set")) + geom_area( aes(y = domi , fill = "Dominance test")) + geom_area(aes(y = others , fill = "Others")) + xlab("Number of variables") + ylab("% of computational time") + ggtitle("No objective branching")
# ```
#
# Relative CPU time of the main components of the branch and bound in function of the number of variable for the branch and bound with exact objective branching. The category "Others" include variable selection, node selection, creation of nodes and other implementation related details.
#
# ```{r,echo=FALSE}
# timerep <- filter(temp,pb=="AS",OB=="exact") %>%
#   group_by(OB,n) %>%
#     summarize(additional_domi = 100, SLUB = mean(100-pcttpsdomiLUB), LB = mean(100-pcttpsdomiLUB-pcttpsSLUB), domi = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB), others = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB-pcttpsdomi) )
#
# timerep %>% ggplot(aes(x=n)) + geom_area( aes(y = additional_domi , fill = "Additional dominance tests for LUBs")) + geom_area( aes(y = SLUB , fill = "Computation of SLUBs")) + geom_area( aes(y = LB , fill = "LB set")) + geom_area( aes(y = domi , fill = "Dominance test")) + geom_area(aes(y = others , fill = "Others")) + xlab("Number of variables") + ylab("% of computational time") + ggtitle("Exact objective branching")
# ```
#
# Relative CPU time of the main components of the branch and bound in function of the number of variable for the branch and bound with the conic objective branching. The category "Others" include variable selection, node selection, creation of nodes and other implementation related details.
#
# ```{r,echo=FALSE}
# timerep <- filter(temp,pb=="AS",OB=="cone") %>%
#   group_by(OB,n) %>%
#     summarize(additional_domi = 100, SLUB = mean(100-pcttpsdomiLUB), LB = mean(100-pcttpsdomiLUB-pcttpsSLUB), domi = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB), others = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB-pcttpsdomi) )
#
# timerep %>% ggplot(aes(x=n)) + geom_area( aes(y = additional_domi , fill = "Additional dominance tests for LUBs")) + geom_area( aes(y = SLUB , fill = "Computation of SLUBs")) + geom_area( aes(y = LB , fill = "LB set")) + geom_area( aes(y = domi , fill = "Dominance test")) + geom_area(aes(y = others , fill = "Others")) + xlab("Number of variables") + ylab("% of computational time") + ggtitle("Cone objective branching")
# ```
#
# #### Facility location easy
#
# Proportion of unsolved instances for each objective branching strategy in function of the number of variables for tri-objective Assignment problems.
#
# ```{r,echo=FALSE}
# t <- filter(temp,pb=="FLe") %>% group_by(OB,n) %>% count(solved==1)
# t <- mutate(t,norm = 100*nn/3)
# t %>%
#   ggplot(aes(x=n, y=norm, group=OB, color=OB)) + geom_line() + xlab("number of variables") + ylab("number of instances solved") + ggtitle("Percentage of tri-objective Assignment problem instances solved") + ylim(0,100)
# ```
#
# Relative CPU time of the main components of the branch and bound in function of the number of variable for the branch and bound without objective branching. The category "Others" include variable selection, node selection, creation of nodes and other implementation related details.
#
# ```{r,echo=FALSE}
# # time repartition stat
#
# timerep <- filter(temp,pb=="FLe",OB=="None") %>%
#   group_by(OB,n) %>%
#     summarize(additional_domi = 100, SLUB = mean(100-pcttpsdomiLUB), LB = mean(100-pcttpsdomiLUB-pcttpsSLUB), domi = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB), others = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB-pcttpsdomi) )
#
# timerep %>% ggplot(aes(x=n)) + geom_area( aes(y = additional_domi , fill = "Additional dominance tests for LUBs")) + geom_area( aes(y = SLUB , fill = "Computation of SLUBs")) + geom_area( aes(y = LB , fill = "LB set")) + geom_area( aes(y = domi , fill = "Dominance test")) + geom_area(aes(y = others , fill = "Others")) + xlab("Number of variables") + ylab("% of computational time") + ggtitle("No objective branching")
# ```
#
# Relative CPU time of the main components of the branch and bound in function of the number of variable for the branch and bound with exact objective branching. The category "Others" include variable selection, node selection, creation of nodes and other implementation related details.
#
# ```{r,echo=FALSE}
# timerep <- filter(temp,pb=="FLe",OB=="exact") %>%
#   group_by(OB,n) %>%
#     summarize(additional_domi = 100, SLUB = mean(100-pcttpsdomiLUB), LB = mean(100-pcttpsdomiLUB-pcttpsSLUB), domi = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB), others = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB-pcttpsdomi) )
#
# timerep %>% ggplot(aes(x=n)) + geom_area( aes(y = additional_domi , fill = "Additional dominance tests for LUBs")) + geom_area( aes(y = SLUB , fill = "Computation of SLUBs")) + geom_area( aes(y = LB , fill = "LB set")) + geom_area( aes(y = domi , fill = "Dominance test")) + geom_area(aes(y = others , fill = "Others")) + xlab("Number of variables") + ylab("% of computational time") + ggtitle("Exact objective branching")
# ```
#
# Relative CPU time of the main components of the branch and bound in function of the number of variable for the branch and bound with the conic objective branching. The category "Others" include variable selection, node selection, creation of nodes and other implementation related details.
#
# ```{r,echo=FALSE}
# timerep <- filter(temp,pb=="FLe",OB=="cone") %>%
#   group_by(OB,n) %>%
#     summarize(additional_domi = 100, SLUB = mean(100-pcttpsdomiLUB), LB = mean(100-pcttpsdomiLUB-pcttpsSLUB), domi = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB), others = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB-pcttpsdomi) )
#
# timerep %>% ggplot(aes(x=n)) + geom_area( aes(y = additional_domi , fill = "Additional dominance tests for LUBs")) + geom_area( aes(y = SLUB , fill = "Computation of SLUBs")) + geom_area( aes(y = LB , fill = "LB set")) + geom_area( aes(y = domi , fill = "Dominance test")) + geom_area(aes(y = others , fill = "Others")) + xlab("Number of variables") + ylab("% of computational time") + ggtitle("Cone objective branching")
# ```
#
# #### Facility location hard
#
# Proportion of unsolved instances for each objective branching strategy in function of the number of variables for tri-objective Assignment problems.
#
# ```{r,echo=FALSE}
# t <- filter(temp,pb=="FLh") %>% group_by(OB,n) %>% count(solved==1)
# t <- mutate(t,norm = 100*nn/3)
# t %>%
#   ggplot(aes(x=n, y=norm, group=OB, color=OB)) + geom_line() + xlab("number of variables") + ylab("number of instances solved") + ggtitle("Percentage of tri-objective Assignment problem instances solved") + ylim(0,100)
# ```
#
# Relative CPU time of the main components of the branch and bound in function of the number of variable for the branch and bound without objective branching. The category "Others" include variable selection, node selection, creation of nodes and other implementation related details.
#
# ```{r,echo=FALSE}
# # time repartition stat
#
# timerep <- filter(temp,pb=="FLh",OB=="None") %>%
#   group_by(OB,n) %>%
#     summarize(additional_domi = 100, SLUB = mean(100-pcttpsdomiLUB), LB = mean(100-pcttpsdomiLUB-pcttpsSLUB), domi = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB), others = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB-pcttpsdomi) )
#
# timerep %>% ggplot(aes(x=n)) + geom_area( aes(y = additional_domi , fill = "Additional dominance tests for LUBs")) + geom_area( aes(y = SLUB , fill = "Computation of SLUBs")) + geom_area( aes(y = LB , fill = "LB set")) + geom_area( aes(y = domi , fill = "Dominance test")) + geom_area(aes(y = others , fill = "Others")) + xlab("Number of variables") + ylab("% of computational time") + ggtitle("No objective branching")
# ```
#
# Relative CPU time of the main components of the branch and bound in function of the number of variable for the branch and bound with exact objective branching. The category "Others" include variable selection, node selection, creation of nodes and other implementation related details.
#
# ```{r,echo=FALSE}
# timerep <- filter(temp,pb=="FLh",OB=="exact") %>%
#   group_by(OB,n) %>%
#     summarize(additional_domi = 100, SLUB = mean(100-pcttpsdomiLUB), LB = mean(100-pcttpsdomiLUB-pcttpsSLUB), domi = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB), others = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB-pcttpsdomi) )
#
# timerep %>% ggplot(aes(x=n)) + geom_area( aes(y = additional_domi , fill = "Additional dominance tests for LUBs")) + geom_area( aes(y = SLUB , fill = "Computation of SLUBs")) + geom_area( aes(y = LB , fill = "LB set")) + geom_area( aes(y = domi , fill = "Dominance test")) + geom_area(aes(y = others , fill = "Others")) + xlab("Number of variables") + ylab("% of computational time") + ggtitle("Exact objective branching")
# ```
#
# Relative CPU time of the main components of the branch and bound in function of the number of variable for the branch and bound with the conic objective branching. The category "Others" include variable selection, node selection, creation of nodes and other implementation related details.
#
# ```{r,echo=FALSE}
# timerep <- filter(temp,pb=="FLh",OB=="cone") %>%
#   group_by(OB,n) %>%
#     summarize(additional_domi = 100, SLUB = mean(100-pcttpsdomiLUB), LB = mean(100-pcttpsdomiLUB-pcttpsSLUB), domi = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB), others = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB-pcttpsdomi) )
#
# timerep %>% ggplot(aes(x=n)) + geom_area( aes(y = additional_domi , fill = "Additional dominance tests for LUBs")) + geom_area( aes(y = SLUB , fill = "Computation of SLUBs")) + geom_area( aes(y = LB , fill = "LB set")) + geom_area( aes(y = domi , fill = "Dominance test")) + geom_area(aes(y = others , fill = "Others")) + xlab("Number of variables") + ylab("% of computational time") + ggtitle("Cone objective branching")
# ```
#
#
#
#
#
# ### Range : [1000,2000]
#
# ```{r,echo=FALSE}
# temp <- filter(datOB,coef == "spheredown",rangemin == 1000,rangemax == 2000)
# tab <- filter(temp,solved == 1)
# tab <- temp %>%
#   group_by(pb,n,OB) %>%
#     summarize(avg = mean(tpstotal))
#
# pivot_wider(tab,names_from = OB, values_from = avg)
#
# st <- seq(0,4,by=0.5)
# val1 <- rep(0,length(st))
# t <- filter(temp, OB=="None")
# for (i in 1:length(st)) {
#   bidouille <- count(t,tpstotal <= st[i])
#   bidouille <- filter(bidouille,bidouille[1]!=FALSE)
#   if (count(bidouille) == 0) {
#     numer <- 0
#   }
#   else{
#     numer <- bidouille[[1,2]]
#   }
#   val1[i] <- 100*numer/count(t)[[1]]
# }
# val2 <- rep(0,length(st))
# t <- filter(temp, OB=="exact")
# for (i in 1:length(st)) {
#   bidouille <- count(t,tpstotal <= st[i])
#   bidouille <- filter(bidouille,bidouille[1]!=FALSE)
#   if (count(bidouille) == 0) {
#     numer <- 0
#   }
#   else{
#     numer <- bidouille[[1,2]]
#   }
#   val2[i] <- 100*numer/count(t)[[1]]
# }
# val3 <- rep(0,length(st))
# t <- filter(temp, OB=="cone")
# for (i in 1:length(st)) {
#   bidouille <- count(t,tpstotal <= st[i])
#   bidouille <- filter(bidouille,bidouille[1]!=FALSE)
#   if (count(bidouille) == 0) {
#     numer <- 0
#   }
#   else{
#     numer <- bidouille[[1,2]]
#   }
#   val3[i] <- 100*numer/count(t)[[1]]
# }
# pl <- tibble( step=st , perfBasic=val1, perfOB=val2, perfCone=val3)
# pl %>% ggplot( aes(x=step)) + geom_line(aes(y=perfBasic,colour="none")) + geom_line(aes(y=perfOB,colour="exact")) + geom_line(aes(y=perfCone,colour="cone")) + xlab("time (sec)") + ylab("% of solved instances") + ggtitle("Performance profile of objective branching")
#
# ```
#
# #### Knapsack
#
# Proportion of unsolved instances for each objective branching strategy in function of the number of variables for tri-objective Knapsack problems.
#
# ```{r,echo=FALSE}
# # unsolved stat
#
# t <- filter(temp,pb=="KP") %>% group_by(OB,n) %>% count(solved==1)
# t <- mutate(t,norm = 100*nn/3)
# t %>%
#   ggplot(aes(x=n, y=norm, group=OB, color=OB)) + geom_line() + xlab("number of variables") + ylab("% of instances solved") + ggtitle("Percentage of tri-objective Knapsack problem instances solved") + ylim(0,100)
# ```
#
# Relative CPU time of the main components of the branch and bound in function of the number of variable for the branch and bound without objective branching. The category "Others" include variable selection, node selection, creation of nodes and other implementation related details.
#
# ```{r,echo=FALSE}
# # time repartition stat
#
# timerep <- filter(temp,pb=="KP",OB=="None") %>%
#   group_by(OB,n) %>%
#     summarize(additional_domi = 100, SLUB = mean(100-pcttpsdomiLUB), LB = mean(100-pcttpsdomiLUB-pcttpsSLUB), domi = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB), others = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB-pcttpsdomi) )
#
# timerep %>% ggplot(aes(x=n)) + geom_area( aes(y = additional_domi , fill = "Additional dominance tests for LUBs")) + geom_area( aes(y = SLUB , fill = "Computation of SLUBs")) + geom_area( aes(y = LB , fill = "LB set")) + geom_area( aes(y = domi , fill = "Dominance test")) + geom_area(aes(y = others , fill = "Others")) + xlab("Number of variables") + ylab("% of computational time") + ggtitle("No objective branching")
# ```
#
# Relative CPU time of the main components of the branch and bound in function of the number of variable for the branch and bound with exact objective branching. The category "Others" include variable selection, node selection, creation of nodes and other implementation related details.
#
# ```{r,echo=FALSE}
# timerep <- filter(temp,pb=="KP",OB=="exact") %>%
#   group_by(OB,n) %>%
#     summarize(additional_domi = 100, SLUB = mean(100-pcttpsdomiLUB), LB = mean(100-pcttpsdomiLUB-pcttpsSLUB), domi = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB), others = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB-pcttpsdomi) )
#
# timerep %>% ggplot(aes(x=n)) + geom_area( aes(y = additional_domi , fill = "Additional dominance tests for LUBs")) + geom_area( aes(y = SLUB , fill = "Computation of SLUBs")) + geom_area( aes(y = LB , fill = "LB set")) + geom_area( aes(y = domi , fill = "Dominance test")) + geom_area(aes(y = others , fill = "Others")) + xlab("Number of variables") + ylab("% of computational time") + ggtitle("Exact objective branching")
# ```
#
# Relative CPU time of the main components of the branch and bound in function of the number of variable for the branch and bound with the conic objective branching. The category "Others" include variable selection, node selection, creation of nodes and other implementation related details.
#
# ```{r,echo=FALSE}
# timerep <- filter(temp,pb=="KP",OB=="cone") %>%
#   group_by(OB,n) %>%
#     summarize(additional_domi = 100, SLUB = mean(100-pcttpsdomiLUB), LB = mean(100-pcttpsdomiLUB-pcttpsSLUB), domi = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB), others = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB-pcttpsdomi) )
#
# timerep %>% ggplot(aes(x=n)) + geom_area( aes(y = additional_domi , fill = "Additional dominance tests for LUBs")) + geom_area( aes(y = SLUB , fill = "Computation of SLUBs")) + geom_area( aes(y = LB , fill = "LB set")) + geom_area( aes(y = domi , fill = "Dominance test")) + geom_area(aes(y = others , fill = "Others")) + xlab("Number of variables") + ylab("% of computational time") + ggtitle("Cone objective branching")
# ```
#
# #### Assignment
#
# Proportion of unsolved instances for each objective branching strategy in function of the number of variables for tri-objective Assignment problems.
#
# ```{r,echo=FALSE}
# t <- filter(temp,pb=="AS") %>% group_by(OB,n) %>% count(solved==1)
# t <- mutate(t,norm = 100*nn/3)
# t %>%
#   ggplot(aes(x=n, y=norm, group=OB, color=OB)) + geom_line() + xlab("number of variables") + ylab("number of instances solved") + ggtitle("Percentage of tri-objective Assignment problem instances solved") + ylim(0,100)
# ```
#
# Relative CPU time of the main components of the branch and bound in function of the number of variable for the branch and bound without objective branching. The category "Others" include variable selection, node selection, creation of nodes and other implementation related details.
#
# ```{r,echo=FALSE}
# # time repartition stat
#
# timerep <- filter(temp,pb=="AS",OB=="None") %>%
#   group_by(OB,n) %>%
#     summarize(additional_domi = 100, SLUB = mean(100-pcttpsdomiLUB), LB = mean(100-pcttpsdomiLUB-pcttpsSLUB), domi = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB), others = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB-pcttpsdomi) )
#
# timerep %>% ggplot(aes(x=n)) + geom_area( aes(y = additional_domi , fill = "Additional dominance tests for LUBs")) + geom_area( aes(y = SLUB , fill = "Computation of SLUBs")) + geom_area( aes(y = LB , fill = "LB set")) + geom_area( aes(y = domi , fill = "Dominance test")) + geom_area(aes(y = others , fill = "Others")) + xlab("Number of variables") + ylab("% of computational time") + ggtitle("No objective branching")
# ```
#
# Relative CPU time of the main components of the branch and bound in function of the number of variable for the branch and bound with exact objective branching. The category "Others" include variable selection, node selection, creation of nodes and other implementation related details.
#
# ```{r,echo=FALSE}
# timerep <- filter(temp,pb=="AS",OB=="exact") %>%
#   group_by(OB,n) %>%
#     summarize(additional_domi = 100, SLUB = mean(100-pcttpsdomiLUB), LB = mean(100-pcttpsdomiLUB-pcttpsSLUB), domi = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB), others = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB-pcttpsdomi) )
#
# timerep %>% ggplot(aes(x=n)) + geom_area( aes(y = additional_domi , fill = "Additional dominance tests for LUBs")) + geom_area( aes(y = SLUB , fill = "Computation of SLUBs")) + geom_area( aes(y = LB , fill = "LB set")) + geom_area( aes(y = domi , fill = "Dominance test")) + geom_area(aes(y = others , fill = "Others")) + xlab("Number of variables") + ylab("% of computational time") + ggtitle("Exact objective branching")
# ```
#
# Relative CPU time of the main components of the branch and bound in function of the number of variable for the branch and bound with the conic objective branching. The category "Others" include variable selection, node selection, creation of nodes and other implementation related details.
#
# ```{r,echo=FALSE}
# timerep <- filter(temp,pb=="AS",OB=="cone") %>%
#   group_by(OB,n) %>%
#     summarize(additional_domi = 100, SLUB = mean(100-pcttpsdomiLUB), LB = mean(100-pcttpsdomiLUB-pcttpsSLUB), domi = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB), others = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB-pcttpsdomi) )
#
# timerep %>% ggplot(aes(x=n)) + geom_area( aes(y = additional_domi , fill = "Additional dominance tests for LUBs")) + geom_area( aes(y = SLUB , fill = "Computation of SLUBs")) + geom_area( aes(y = LB , fill = "LB set")) + geom_area( aes(y = domi , fill = "Dominance test")) + geom_area(aes(y = others , fill = "Others")) + xlab("Number of variables") + ylab("% of computational time") + ggtitle("Cone objective branching")
# ```
#
# #### Facility location easy
#
# Proportion of unsolved instances for each objective branching strategy in function of the number of variables for tri-objective Assignment problems.
#
# ```{r,echo=FALSE}
# t <- filter(temp,pb=="FLe") %>% group_by(OB,n) %>% count(solved==1)
# t <- mutate(t,norm = 100*nn/3)
# t %>%
#   ggplot(aes(x=n, y=norm, group=OB, color=OB)) + geom_line() + xlab("number of variables") + ylab("number of instances solved") + ggtitle("Percentage of tri-objective Assignment problem instances solved") + ylim(0,100)
# ```
#
# Relative CPU time of the main components of the branch and bound in function of the number of variable for the branch and bound without objective branching. The category "Others" include variable selection, node selection, creation of nodes and other implementation related details.
#
# ```{r,echo=FALSE}
# # time repartition stat
#
# timerep <- filter(temp,pb=="FLe",OB=="None") %>%
#   group_by(OB,n) %>%
#     summarize(additional_domi = 100, SLUB = mean(100-pcttpsdomiLUB), LB = mean(100-pcttpsdomiLUB-pcttpsSLUB), domi = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB), others = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB-pcttpsdomi) )
#
# timerep %>% ggplot(aes(x=n)) + geom_area( aes(y = additional_domi , fill = "Additional dominance tests for LUBs")) + geom_area( aes(y = SLUB , fill = "Computation of SLUBs")) + geom_area( aes(y = LB , fill = "LB set")) + geom_area( aes(y = domi , fill = "Dominance test")) + geom_area(aes(y = others , fill = "Others")) + xlab("Number of variables") + ylab("% of computational time") + ggtitle("No objective branching")
# ```
#
# Relative CPU time of the main components of the branch and bound in function of the number of variable for the branch and bound with exact objective branching. The category "Others" include variable selection, node selection, creation of nodes and other implementation related details.
#
# ```{r,echo=FALSE}
# timerep <- filter(temp,pb=="FLe",OB=="exact") %>%
#   group_by(OB,n) %>%
#     summarize(additional_domi = 100, SLUB = mean(100-pcttpsdomiLUB), LB = mean(100-pcttpsdomiLUB-pcttpsSLUB), domi = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB), others = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB-pcttpsdomi) )
#
# timerep %>% ggplot(aes(x=n)) + geom_area( aes(y = additional_domi , fill = "Additional dominance tests for LUBs")) + geom_area( aes(y = SLUB , fill = "Computation of SLUBs")) + geom_area( aes(y = LB , fill = "LB set")) + geom_area( aes(y = domi , fill = "Dominance test")) + geom_area(aes(y = others , fill = "Others")) + xlab("Number of variables") + ylab("% of computational time") + ggtitle("Exact objective branching")
# ```
#
# Relative CPU time of the main components of the branch and bound in function of the number of variable for the branch and bound with the conic objective branching. The category "Others" include variable selection, node selection, creation of nodes and other implementation related details.
#
# ```{r,echo=FALSE}
# timerep <- filter(temp,pb=="FLe",OB=="cone") %>%
#   group_by(OB,n) %>%
#     summarize(additional_domi = 100, SLUB = mean(100-pcttpsdomiLUB), LB = mean(100-pcttpsdomiLUB-pcttpsSLUB), domi = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB), others = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB-pcttpsdomi) )
#
# timerep %>% ggplot(aes(x=n)) + geom_area( aes(y = additional_domi , fill = "Additional dominance tests for LUBs")) + geom_area( aes(y = SLUB , fill = "Computation of SLUBs")) + geom_area( aes(y = LB , fill = "LB set")) + geom_area( aes(y = domi , fill = "Dominance test")) + geom_area(aes(y = others , fill = "Others")) + xlab("Number of variables") + ylab("% of computational time") + ggtitle("Cone objective branching")
# ```
#
# #### Facility location hard
#
# Proportion of unsolved instances for each objective branching strategy in function of the number of variables for tri-objective Assignment problems.
#
# ```{r,echo=FALSE}
# t <- filter(temp,pb=="FLh") %>% group_by(OB,n) %>% count(solved==1)
# t <- mutate(t,norm = 100*nn/3)
# t %>%
#   ggplot(aes(x=n, y=norm, group=OB, color=OB)) + geom_line() + xlab("number of variables") + ylab("number of instances solved") + ggtitle("Percentage of tri-objective Assignment problem instances solved") + ylim(0,100)
# ```
#
# Relative CPU time of the main components of the branch and bound in function of the number of variable for the branch and bound without objective branching. The category "Others" include variable selection, node selection, creation of nodes and other implementation related details.
#
# ```{r,echo=FALSE}
# # time repartition stat
#
# timerep <- filter(temp,pb=="FLh",OB=="None") %>%
#   group_by(OB,n) %>%
#     summarize(additional_domi = 100, SLUB = mean(100-pcttpsdomiLUB), LB = mean(100-pcttpsdomiLUB-pcttpsSLUB), domi = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB), others = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB-pcttpsdomi) )
#
# timerep %>% ggplot(aes(x=n)) + geom_area( aes(y = additional_domi , fill = "Additional dominance tests for LUBs")) + geom_area( aes(y = SLUB , fill = "Computation of SLUBs")) + geom_area( aes(y = LB , fill = "LB set")) + geom_area( aes(y = domi , fill = "Dominance test")) + geom_area(aes(y = others , fill = "Others")) + xlab("Number of variables") + ylab("% of computational time") + ggtitle("No objective branching")
# ```
#
# Relative CPU time of the main components of the branch and bound in function of the number of variable for the branch and bound with exact objective branching. The category "Others" include variable selection, node selection, creation of nodes and other implementation related details.
#
# ```{r,echo=FALSE}
# timerep <- filter(temp,pb=="FLh",OB=="exact") %>%
#   group_by(OB,n) %>%
#     summarize(additional_domi = 100, SLUB = mean(100-pcttpsdomiLUB), LB = mean(100-pcttpsdomiLUB-pcttpsSLUB), domi = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB), others = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB-pcttpsdomi) )
#
# timerep %>% ggplot(aes(x=n)) + geom_area( aes(y = additional_domi , fill = "Additional dominance tests for LUBs")) + geom_area( aes(y = SLUB , fill = "Computation of SLUBs")) + geom_area( aes(y = LB , fill = "LB set")) + geom_area( aes(y = domi , fill = "Dominance test")) + geom_area(aes(y = others , fill = "Others")) + xlab("Number of variables") + ylab("% of computational time") + ggtitle("Exact objective branching")
# ```
#
# Relative CPU time of the main components of the branch and bound in function of the number of variable for the branch and bound with the conic objective branching. The category "Others" include variable selection, node selection, creation of nodes and other implementation related details.
#
# ```{r,echo=FALSE}
# timerep <- filter(temp,pb=="FLh",OB=="cone") %>%
#   group_by(OB,n) %>%
#     summarize(additional_domi = 100, SLUB = mean(100-pcttpsdomiLUB), LB = mean(100-pcttpsdomiLUB-pcttpsSLUB), domi = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB), others = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB-pcttpsdomi) )
#
# timerep %>% ggplot(aes(x=n)) + geom_area( aes(y = additional_domi , fill = "Additional dominance tests for LUBs")) + geom_area( aes(y = SLUB , fill = "Computation of SLUBs")) + geom_area( aes(y = LB , fill = "LB set")) + geom_area( aes(y = domi , fill = "Dominance test")) + geom_area(aes(y = others , fill = "Others")) + xlab("Number of variables") + ylab("% of computational time") + ggtitle("Cone objective branching")
# ```
#
#
#
# ## Upper sphere
#
# ### Range : [1,10]
#
# ```{r,echo=FALSE}
# temp <- filter(datOB,coef == "sphereup",rangemin == 1,rangemax == 10)
# tab <- filter(temp,solved == 1)
# tab <- temp %>%
#   group_by(pb,n,OB) %>%
#     summarize(avg = mean(tpstotal))
#
# pivot_wider(tab,names_from = OB, values_from = avg)
#
# st <- seq(0,4,by=0.5)
# val1 <- rep(0,length(st))
# t <- filter(temp, OB=="None")
# for (i in 1:length(st)) {
#   bidouille <- count(t,tpstotal <= st[i])
#   bidouille <- filter(bidouille,bidouille[1]!=FALSE)
#   if (count(bidouille) == 0) {
#     numer <- 0
#   }
#   else{
#     numer <- bidouille[[1,2]]
#   }
#   val1[i] <- 100*numer/count(t)[[1]]
# }
# val2 <- rep(0,length(st))
# t <- filter(temp, OB=="exact")
# for (i in 1:length(st)) {
#   bidouille <- count(t,tpstotal <= st[i])
#   bidouille <- filter(bidouille,bidouille[1]!=FALSE)
#   if (count(bidouille) == 0) {
#     numer <- 0
#   }
#   else{
#     numer <- bidouille[[1,2]]
#   }
#   val2[i] <- 100*numer/count(t)[[1]]
# }
# val3 <- rep(0,length(st))
# t <- filter(temp, OB=="cone")
# for (i in 1:length(st)) {
#   bidouille <- count(t,tpstotal <= st[i])
#   bidouille <- filter(bidouille,bidouille[1]!=FALSE)
#   if (count(bidouille) == 0) {
#     numer <- 0
#   }
#   else{
#     numer <- bidouille[[1,2]]
#   }
#   val3[i] <- 100*numer/count(t)[[1]]
# }
# pl <- tibble( step=st , perfBasic=val1, perfOB=val2, perfCone=val3)
# pl %>% ggplot( aes(x=step)) + geom_line(aes(y=perfBasic,colour="none")) + geom_line(aes(y=perfOB,colour="exact")) + geom_line(aes(y=perfCone,colour="cone")) + xlab("time (sec)") + ylab("% of solved instances") + ggtitle("Performance profile of objective branching")
#
# ```
#
# #### Knapsack
#
# Proportion of unsolved instances for each objective branching strategy in function of the number of variables for tri-objective Knapsack problems.
#
# ```{r,echo=FALSE}
# # unsolved stat
#
# t <- filter(temp,pb=="KP") %>% group_by(OB,n) %>% count(solved==1)
# t <- mutate(t,norm = 100*nn/3)
# t %>%
#   ggplot(aes(x=n, y=norm, group=OB, color=OB)) + geom_line() + xlab("number of variables") + ylab("% of instances solved") + ggtitle("Percentage of tri-objective Knapsack problem instances solved") + ylim(0,100)
# ```
#
# Relative CPU time of the main components of the branch and bound in function of the number of variable for the branch and bound without objective branching. The category "Others" include variable selection, node selection, creation of nodes and other implementation related details.
#
# ```{r,echo=FALSE}
# # time repartition stat
#
# timerep <- filter(temp,pb=="KP",OB=="None") %>%
#   group_by(OB,n) %>%
#     summarize(additional_domi = 100, SLUB = mean(100-pcttpsdomiLUB), LB = mean(100-pcttpsdomiLUB-pcttpsSLUB), domi = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB), others = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB-pcttpsdomi) )
#
# timerep %>% ggplot(aes(x=n)) + geom_area( aes(y = additional_domi , fill = "Additional dominance tests for LUBs")) + geom_area( aes(y = SLUB , fill = "Computation of SLUBs")) + geom_area( aes(y = LB , fill = "LB set")) + geom_area( aes(y = domi , fill = "Dominance test")) + geom_area(aes(y = others , fill = "Others")) + xlab("Number of variables") + ylab("% of computational time") + ggtitle("No objective branching")
# ```
#
# Relative CPU time of the main components of the branch and bound in function of the number of variable for the branch and bound with exact objective branching. The category "Others" include variable selection, node selection, creation of nodes and other implementation related details.
#
# ```{r,echo=FALSE}
# timerep <- filter(temp,pb=="KP",OB=="exact") %>%
#   group_by(OB,n) %>%
#     summarize(additional_domi = 100, SLUB = mean(100-pcttpsdomiLUB), LB = mean(100-pcttpsdomiLUB-pcttpsSLUB), domi = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB), others = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB-pcttpsdomi) )
#
# timerep %>% ggplot(aes(x=n)) + geom_area( aes(y = additional_domi , fill = "Additional dominance tests for LUBs")) + geom_area( aes(y = SLUB , fill = "Computation of SLUBs")) + geom_area( aes(y = LB , fill = "LB set")) + geom_area( aes(y = domi , fill = "Dominance test")) + geom_area(aes(y = others , fill = "Others")) + xlab("Number of variables") + ylab("% of computational time") + ggtitle("Exact objective branching")
# ```
#
# Relative CPU time of the main components of the branch and bound in function of the number of variable for the branch and bound with the conic objective branching. The category "Others" include variable selection, node selection, creation of nodes and other implementation related details.
#
# ```{r,echo=FALSE}
# timerep <- filter(temp,pb=="KP",OB=="cone") %>%
#   group_by(OB,n) %>%
#     summarize(additional_domi = 100, SLUB = mean(100-pcttpsdomiLUB), LB = mean(100-pcttpsdomiLUB-pcttpsSLUB), domi = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB), others = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB-pcttpsdomi) )
#
# timerep %>% ggplot(aes(x=n)) + geom_area( aes(y = additional_domi , fill = "Additional dominance tests for LUBs")) + geom_area( aes(y = SLUB , fill = "Computation of SLUBs")) + geom_area( aes(y = LB , fill = "LB set")) + geom_area( aes(y = domi , fill = "Dominance test")) + geom_area(aes(y = others , fill = "Others")) + xlab("Number of variables") + ylab("% of computational time") + ggtitle("Cone objective branching")
# ```
#
# #### Assignment
#
# Proportion of unsolved instances for each objective branching strategy in function of the number of variables for tri-objective Assignment problems.
#
# ```{r,echo=FALSE}
# t <- filter(temp,pb=="AS") %>% group_by(OB,n) %>% count(solved==1)
# t <- mutate(t,norm = 100*nn/3)
# t %>%
#   ggplot(aes(x=n, y=norm, group=OB, color=OB)) + geom_line() + xlab("number of variables") + ylab("number of instances solved") + ggtitle("Percentage of tri-objective Assignment problem instances solved") + ylim(0,100)
# ```
#
# Relative CPU time of the main components of the branch and bound in function of the number of variable for the branch and bound without objective branching. The category "Others" include variable selection, node selection, creation of nodes and other implementation related details.
#
# ```{r,echo=FALSE}
# # time repartition stat
#
# timerep <- filter(temp,pb=="AS",OB=="None") %>%
#   group_by(OB,n) %>%
#     summarize(additional_domi = 100, SLUB = mean(100-pcttpsdomiLUB), LB = mean(100-pcttpsdomiLUB-pcttpsSLUB), domi = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB), others = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB-pcttpsdomi) )
#
# timerep %>% ggplot(aes(x=n)) + geom_area( aes(y = additional_domi , fill = "Additional dominance tests for LUBs")) + geom_area( aes(y = SLUB , fill = "Computation of SLUBs")) + geom_area( aes(y = LB , fill = "LB set")) + geom_area( aes(y = domi , fill = "Dominance test")) + geom_area(aes(y = others , fill = "Others")) + xlab("Number of variables") + ylab("% of computational time") + ggtitle("No objective branching")
# ```
#
# Relative CPU time of the main components of the branch and bound in function of the number of variable for the branch and bound with exact objective branching. The category "Others" include variable selection, node selection, creation of nodes and other implementation related details.
#
# ```{r,echo=FALSE}
# timerep <- filter(temp,pb=="AS",OB=="exact") %>%
#   group_by(OB,n) %>%
#     summarize(additional_domi = 100, SLUB = mean(100-pcttpsdomiLUB), LB = mean(100-pcttpsdomiLUB-pcttpsSLUB), domi = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB), others = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB-pcttpsdomi) )
#
# timerep %>% ggplot(aes(x=n)) + geom_area( aes(y = additional_domi , fill = "Additional dominance tests for LUBs")) + geom_area( aes(y = SLUB , fill = "Computation of SLUBs")) + geom_area( aes(y = LB , fill = "LB set")) + geom_area( aes(y = domi , fill = "Dominance test")) + geom_area(aes(y = others , fill = "Others")) + xlab("Number of variables") + ylab("% of computational time") + ggtitle("Exact objective branching")
# ```
#
# Relative CPU time of the main components of the branch and bound in function of the number of variable for the branch and bound with the conic objective branching. The category "Others" include variable selection, node selection, creation of nodes and other implementation related details.
#
# ```{r,echo=FALSE}
# timerep <- filter(temp,pb=="AS",OB=="cone") %>%
#   group_by(OB,n) %>%
#     summarize(additional_domi = 100, SLUB = mean(100-pcttpsdomiLUB), LB = mean(100-pcttpsdomiLUB-pcttpsSLUB), domi = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB), others = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB-pcttpsdomi) )
#
# timerep %>% ggplot(aes(x=n)) + geom_area( aes(y = additional_domi , fill = "Additional dominance tests for LUBs")) + geom_area( aes(y = SLUB , fill = "Computation of SLUBs")) + geom_area( aes(y = LB , fill = "LB set")) + geom_area( aes(y = domi , fill = "Dominance test")) + geom_area(aes(y = others , fill = "Others")) + xlab("Number of variables") + ylab("% of computational time") + ggtitle("Cone objective branching")
# ```
#
# #### Facility location easy
#
# Proportion of unsolved instances for each objective branching strategy in function of the number of variables for tri-objective Assignment problems.
#
# ```{r,echo=FALSE}
# t <- filter(temp,pb=="FLe") %>% group_by(OB,n) %>% count(solved==1)
# t <- mutate(t,norm = 100*nn/3)
# t %>%
#   ggplot(aes(x=n, y=norm, group=OB, color=OB)) + geom_line() + xlab("number of variables") + ylab("number of instances solved") + ggtitle("Percentage of tri-objective Assignment problem instances solved") + ylim(0,100)
# ```
#
# Relative CPU time of the main components of the branch and bound in function of the number of variable for the branch and bound without objective branching. The category "Others" include variable selection, node selection, creation of nodes and other implementation related details.
#
# ```{r,echo=FALSE}
# # time repartition stat
#
# timerep <- filter(temp,pb=="FLe",OB=="None") %>%
#   group_by(OB,n) %>%
#     summarize(additional_domi = 100, SLUB = mean(100-pcttpsdomiLUB), LB = mean(100-pcttpsdomiLUB-pcttpsSLUB), domi = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB), others = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB-pcttpsdomi) )
#
# timerep %>% ggplot(aes(x=n)) + geom_area( aes(y = additional_domi , fill = "Additional dominance tests for LUBs")) + geom_area( aes(y = SLUB , fill = "Computation of SLUBs")) + geom_area( aes(y = LB , fill = "LB set")) + geom_area( aes(y = domi , fill = "Dominance test")) + geom_area(aes(y = others , fill = "Others")) + xlab("Number of variables") + ylab("% of computational time") + ggtitle("No objective branching")
# ```
#
# Relative CPU time of the main components of the branch and bound in function of the number of variable for the branch and bound with exact objective branching. The category "Others" include variable selection, node selection, creation of nodes and other implementation related details.
#
# ```{r,echo=FALSE}
# timerep <- filter(temp,pb=="FLe",OB=="exact") %>%
#   group_by(OB,n) %>%
#     summarize(additional_domi = 100, SLUB = mean(100-pcttpsdomiLUB), LB = mean(100-pcttpsdomiLUB-pcttpsSLUB), domi = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB), others = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB-pcttpsdomi) )
#
# timerep %>% ggplot(aes(x=n)) + geom_area( aes(y = additional_domi , fill = "Additional dominance tests for LUBs")) + geom_area( aes(y = SLUB , fill = "Computation of SLUBs")) + geom_area( aes(y = LB , fill = "LB set")) + geom_area( aes(y = domi , fill = "Dominance test")) + geom_area(aes(y = others , fill = "Others")) + xlab("Number of variables") + ylab("% of computational time") + ggtitle("Exact objective branching")
# ```
#
# Relative CPU time of the main components of the branch and bound in function of the number of variable for the branch and bound with the conic objective branching. The category "Others" include variable selection, node selection, creation of nodes and other implementation related details.
#
# ```{r,echo=FALSE}
# timerep <- filter(temp,pb=="FLe",OB=="cone") %>%
#   group_by(OB,n) %>%
#     summarize(additional_domi = 100, SLUB = mean(100-pcttpsdomiLUB), LB = mean(100-pcttpsdomiLUB-pcttpsSLUB), domi = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB), others = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB-pcttpsdomi) )
#
# timerep %>% ggplot(aes(x=n)) + geom_area( aes(y = additional_domi , fill = "Additional dominance tests for LUBs")) + geom_area( aes(y = SLUB , fill = "Computation of SLUBs")) + geom_area( aes(y = LB , fill = "LB set")) + geom_area( aes(y = domi , fill = "Dominance test")) + geom_area(aes(y = others , fill = "Others")) + xlab("Number of variables") + ylab("% of computational time") + ggtitle("Cone objective branching")
# ```
#
# #### Facility location hard
#
# Proportion of unsolved instances for each objective branching strategy in function of the number of variables for tri-objective Assignment problems.
#
# ```{r,echo=FALSE}
# t <- filter(temp,pb=="FLh") %>% group_by(OB,n) %>% count(solved==1)
# t <- mutate(t,norm = 100*nn/3)
# t %>%
#   ggplot(aes(x=n, y=norm, group=OB, color=OB)) + geom_line() + xlab("number of variables") + ylab("number of instances solved") + ggtitle("Percentage of tri-objective Assignment problem instances solved") + ylim(0,100)
# ```
#
# Relative CPU time of the main components of the branch and bound in function of the number of variable for the branch and bound without objective branching. The category "Others" include variable selection, node selection, creation of nodes and other implementation related details.
#
# ```{r,echo=FALSE}
# # time repartition stat
#
# timerep <- filter(temp,pb=="FLh",OB=="None") %>%
#   group_by(OB,n) %>%
#     summarize(additional_domi = 100, SLUB = mean(100-pcttpsdomiLUB), LB = mean(100-pcttpsdomiLUB-pcttpsSLUB), domi = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB), others = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB-pcttpsdomi) )
#
# timerep %>% ggplot(aes(x=n)) + geom_area( aes(y = additional_domi , fill = "Additional dominance tests for LUBs")) + geom_area( aes(y = SLUB , fill = "Computation of SLUBs")) + geom_area( aes(y = LB , fill = "LB set")) + geom_area( aes(y = domi , fill = "Dominance test")) + geom_area(aes(y = others , fill = "Others")) + xlab("Number of variables") + ylab("% of computational time") + ggtitle("No objective branching")
# ```
#
# Relative CPU time of the main components of the branch and bound in function of the number of variable for the branch and bound with exact objective branching. The category "Others" include variable selection, node selection, creation of nodes and other implementation related details.
#
# ```{r,echo=FALSE}
# timerep <- filter(temp,pb=="FLh",OB=="exact") %>%
#   group_by(OB,n) %>%
#     summarize(additional_domi = 100, SLUB = mean(100-pcttpsdomiLUB), LB = mean(100-pcttpsdomiLUB-pcttpsSLUB), domi = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB), others = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB-pcttpsdomi) )
#
# timerep %>% ggplot(aes(x=n)) + geom_area( aes(y = additional_domi , fill = "Additional dominance tests for LUBs")) + geom_area( aes(y = SLUB , fill = "Computation of SLUBs")) + geom_area( aes(y = LB , fill = "LB set")) + geom_area( aes(y = domi , fill = "Dominance test")) + geom_area(aes(y = others , fill = "Others")) + xlab("Number of variables") + ylab("% of computational time") + ggtitle("Exact objective branching")
# ```
#
# Relative CPU time of the main components of the branch and bound in function of the number of variable for the branch and bound with the conic objective branching. The category "Others" include variable selection, node selection, creation of nodes and other implementation related details.
#
# ```{r,echo=FALSE}
# timerep <- filter(temp,pb=="FLh",OB=="cone") %>%
#   group_by(OB,n) %>%
#     summarize(additional_domi = 100, SLUB = mean(100-pcttpsdomiLUB), LB = mean(100-pcttpsdomiLUB-pcttpsSLUB), domi = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB), others = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB-pcttpsdomi) )
#
# timerep %>% ggplot(aes(x=n)) + geom_area( aes(y = additional_domi , fill = "Additional dominance tests for LUBs")) + geom_area( aes(y = SLUB , fill = "Computation of SLUBs")) + geom_area( aes(y = LB , fill = "LB set")) + geom_area( aes(y = domi , fill = "Dominance test")) + geom_area(aes(y = others , fill = "Others")) + xlab("Number of variables") + ylab("% of computational time") + ggtitle("Cone objective branching")
# ```
#
#
# ### Range : [1,1000]
#
# ```{r,echo=FALSE}
# temp <- filter(datOB,coef == "sphereup",rangemin == 1,rangemax == 1000)
# tab <- filter(temp,solved == 1)
# tab <- temp %>%
#   group_by(pb,n,OB) %>%
#     summarize(avg = mean(tpstotal))
#
# pivot_wider(tab,names_from = OB, values_from = avg)
#
# st <- seq(0,4,by=0.5)
# val1 <- rep(0,length(st))
# t <- filter(temp, OB=="None")
# for (i in 1:length(st)) {
#   bidouille <- count(t,tpstotal <= st[i])
#   bidouille <- filter(bidouille,bidouille[1]!=FALSE)
#   if (count(bidouille) == 0) {
#     numer <- 0
#   }
#   else{
#     numer <- bidouille[[1,2]]
#   }
#   val1[i] <- 100*numer/count(t)[[1]]
# }
# val2 <- rep(0,length(st))
# t <- filter(temp, OB=="exact")
# for (i in 1:length(st)) {
#   bidouille <- count(t,tpstotal <= st[i])
#   bidouille <- filter(bidouille,bidouille[1]!=FALSE)
#   if (count(bidouille) == 0) {
#     numer <- 0
#   }
#   else{
#     numer <- bidouille[[1,2]]
#   }
#   val2[i] <- 100*numer/count(t)[[1]]
# }
# val3 <- rep(0,length(st))
# t <- filter(temp, OB=="cone")
# for (i in 1:length(st)) {
#   bidouille <- count(t,tpstotal <= st[i])
#   bidouille <- filter(bidouille,bidouille[1]!=FALSE)
#   if (count(bidouille) == 0) {
#     numer <- 0
#   }
#   else{
#     numer <- bidouille[[1,2]]
#   }
#   val3[i] <- 100*numer/count(t)[[1]]
# }
# pl <- tibble( step=st , perfBasic=val1, perfOB=val2, perfCone=val3)
# pl %>% ggplot( aes(x=step)) + geom_line(aes(y=perfBasic,colour="none")) + geom_line(aes(y=perfOB,colour="exact")) + geom_line(aes(y=perfCone,colour="cone")) + xlab("time (sec)") + ylab("% of solved instances") + ggtitle("Performance profile of objective branching")
#
# ```
#
# #### Knapsack
#
# Proportion of unsolved instances for each objective branching strategy in function of the number of variables for tri-objective Knapsack problems.
#
# ```{r,echo=FALSE}
# # unsolved stat
#
# t <- filter(temp,pb=="KP") %>% group_by(OB,n) %>% count(solved==1)
# t <- mutate(t,norm = 100*nn/3)
# t %>%
#   ggplot(aes(x=n, y=norm, group=OB, color=OB)) + geom_line() + xlab("number of variables") + ylab("% of instances solved") + ggtitle("Percentage of tri-objective Knapsack problem instances solved") + ylim(0,100)
# ```
#
# Relative CPU time of the main components of the branch and bound in function of the number of variable for the branch and bound without objective branching. The category "Others" include variable selection, node selection, creation of nodes and other implementation related details.
#
# ```{r,echo=FALSE}
# # time repartition stat
#
# timerep <- filter(temp,pb=="KP",OB=="None") %>%
#   group_by(OB,n) %>%
#     summarize(additional_domi = 100, SLUB = mean(100-pcttpsdomiLUB), LB = mean(100-pcttpsdomiLUB-pcttpsSLUB), domi = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB), others = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB-pcttpsdomi) )
#
# timerep %>% ggplot(aes(x=n)) + geom_area( aes(y = additional_domi , fill = "Additional dominance tests for LUBs")) + geom_area( aes(y = SLUB , fill = "Computation of SLUBs")) + geom_area( aes(y = LB , fill = "LB set")) + geom_area( aes(y = domi , fill = "Dominance test")) + geom_area(aes(y = others , fill = "Others")) + xlab("Number of variables") + ylab("% of computational time") + ggtitle("No objective branching")
# ```
#
# Relative CPU time of the main components of the branch and bound in function of the number of variable for the branch and bound with exact objective branching. The category "Others" include variable selection, node selection, creation of nodes and other implementation related details.
#
# ```{r,echo=FALSE}
# timerep <- filter(temp,pb=="KP",OB=="exact") %>%
#   group_by(OB,n) %>%
#     summarize(additional_domi = 100, SLUB = mean(100-pcttpsdomiLUB), LB = mean(100-pcttpsdomiLUB-pcttpsSLUB), domi = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB), others = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB-pcttpsdomi) )
#
# timerep %>% ggplot(aes(x=n)) + geom_area( aes(y = additional_domi , fill = "Additional dominance tests for LUBs")) + geom_area( aes(y = SLUB , fill = "Computation of SLUBs")) + geom_area( aes(y = LB , fill = "LB set")) + geom_area( aes(y = domi , fill = "Dominance test")) + geom_area(aes(y = others , fill = "Others")) + xlab("Number of variables") + ylab("% of computational time") + ggtitle("Exact objective branching")
# ```
#
# Relative CPU time of the main components of the branch and bound in function of the number of variable for the branch and bound with the conic objective branching. The category "Others" include variable selection, node selection, creation of nodes and other implementation related details.
#
# ```{r,echo=FALSE}
# timerep <- filter(temp,pb=="KP",OB=="cone") %>%
#   group_by(OB,n) %>%
#     summarize(additional_domi = 100, SLUB = mean(100-pcttpsdomiLUB), LB = mean(100-pcttpsdomiLUB-pcttpsSLUB), domi = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB), others = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB-pcttpsdomi) )
#
# timerep %>% ggplot(aes(x=n)) + geom_area( aes(y = additional_domi , fill = "Additional dominance tests for LUBs")) + geom_area( aes(y = SLUB , fill = "Computation of SLUBs")) + geom_area( aes(y = LB , fill = "LB set")) + geom_area( aes(y = domi , fill = "Dominance test")) + geom_area(aes(y = others , fill = "Others")) + xlab("Number of variables") + ylab("% of computational time") + ggtitle("Cone objective branching")
# ```
#
# #### Assignment
#
# Proportion of unsolved instances for each objective branching strategy in function of the number of variables for tri-objective Assignment problems.
#
# ```{r,echo=FALSE}
# t <- filter(temp,pb=="AS") %>% group_by(OB,n) %>% count(solved==1)
# t <- mutate(t,norm = 100*nn/3)
# t %>%
#   ggplot(aes(x=n, y=norm, group=OB, color=OB)) + geom_line() + xlab("number of variables") + ylab("number of instances solved") + ggtitle("Percentage of tri-objective Assignment problem instances solved") + ylim(0,100)
# ```
#
# Relative CPU time of the main components of the branch and bound in function of the number of variable for the branch and bound without objective branching. The category "Others" include variable selection, node selection, creation of nodes and other implementation related details.
#
# ```{r,echo=FALSE}
# # time repartition stat
#
# timerep <- filter(temp,pb=="AS",OB=="None") %>%
#   group_by(OB,n) %>%
#     summarize(additional_domi = 100, SLUB = mean(100-pcttpsdomiLUB), LB = mean(100-pcttpsdomiLUB-pcttpsSLUB), domi = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB), others = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB-pcttpsdomi) )
#
# timerep %>% ggplot(aes(x=n)) + geom_area( aes(y = additional_domi , fill = "Additional dominance tests for LUBs")) + geom_area( aes(y = SLUB , fill = "Computation of SLUBs")) + geom_area( aes(y = LB , fill = "LB set")) + geom_area( aes(y = domi , fill = "Dominance test")) + geom_area(aes(y = others , fill = "Others")) + xlab("Number of variables") + ylab("% of computational time") + ggtitle("No objective branching")
# ```
#
# Relative CPU time of the main components of the branch and bound in function of the number of variable for the branch and bound with exact objective branching. The category "Others" include variable selection, node selection, creation of nodes and other implementation related details.
#
# ```{r,echo=FALSE}
# timerep <- filter(temp,pb=="AS",OB=="exact") %>%
#   group_by(OB,n) %>%
#     summarize(additional_domi = 100, SLUB = mean(100-pcttpsdomiLUB), LB = mean(100-pcttpsdomiLUB-pcttpsSLUB), domi = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB), others = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB-pcttpsdomi) )
#
# timerep %>% ggplot(aes(x=n)) + geom_area( aes(y = additional_domi , fill = "Additional dominance tests for LUBs")) + geom_area( aes(y = SLUB , fill = "Computation of SLUBs")) + geom_area( aes(y = LB , fill = "LB set")) + geom_area( aes(y = domi , fill = "Dominance test")) + geom_area(aes(y = others , fill = "Others")) + xlab("Number of variables") + ylab("% of computational time") + ggtitle("Exact objective branching")
# ```
#
# Relative CPU time of the main components of the branch and bound in function of the number of variable for the branch and bound with the conic objective branching. The category "Others" include variable selection, node selection, creation of nodes and other implementation related details.
#
# ```{r,echo=FALSE}
# timerep <- filter(temp,pb=="AS",OB=="cone") %>%
#   group_by(OB,n) %>%
#     summarize(additional_domi = 100, SLUB = mean(100-pcttpsdomiLUB), LB = mean(100-pcttpsdomiLUB-pcttpsSLUB), domi = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB), others = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB-pcttpsdomi) )
#
# timerep %>% ggplot(aes(x=n)) + geom_area( aes(y = additional_domi , fill = "Additional dominance tests for LUBs")) + geom_area( aes(y = SLUB , fill = "Computation of SLUBs")) + geom_area( aes(y = LB , fill = "LB set")) + geom_area( aes(y = domi , fill = "Dominance test")) + geom_area(aes(y = others , fill = "Others")) + xlab("Number of variables") + ylab("% of computational time") + ggtitle("Cone objective branching")
# ```
#
# #### Facility location easy
#
# Proportion of unsolved instances for each objective branching strategy in function of the number of variables for tri-objective Assignment problems.
#
# ```{r,echo=FALSE}
# t <- filter(temp,pb=="FLe") %>% group_by(OB,n) %>% count(solved==1)
# t <- mutate(t,norm = 100*nn/3)
# t %>%
#   ggplot(aes(x=n, y=norm, group=OB, color=OB)) + geom_line() + xlab("number of variables") + ylab("number of instances solved") + ggtitle("Percentage of tri-objective Assignment problem instances solved") + ylim(0,100)
# ```
#
# Relative CPU time of the main components of the branch and bound in function of the number of variable for the branch and bound without objective branching. The category "Others" include variable selection, node selection, creation of nodes and other implementation related details.
#
# ```{r,echo=FALSE}
# # time repartition stat
#
# timerep <- filter(temp,pb=="FLe",OB=="None") %>%
#   group_by(OB,n) %>%
#     summarize(additional_domi = 100, SLUB = mean(100-pcttpsdomiLUB), LB = mean(100-pcttpsdomiLUB-pcttpsSLUB), domi = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB), others = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB-pcttpsdomi) )
#
# timerep %>% ggplot(aes(x=n)) + geom_area( aes(y = additional_domi , fill = "Additional dominance tests for LUBs")) + geom_area( aes(y = SLUB , fill = "Computation of SLUBs")) + geom_area( aes(y = LB , fill = "LB set")) + geom_area( aes(y = domi , fill = "Dominance test")) + geom_area(aes(y = others , fill = "Others")) + xlab("Number of variables") + ylab("% of computational time") + ggtitle("No objective branching")
# ```
#
# Relative CPU time of the main components of the branch and bound in function of the number of variable for the branch and bound with exact objective branching. The category "Others" include variable selection, node selection, creation of nodes and other implementation related details.
#
# ```{r,echo=FALSE}
# timerep <- filter(temp,pb=="FLe",OB=="exact") %>%
#   group_by(OB,n) %>%
#     summarize(additional_domi = 100, SLUB = mean(100-pcttpsdomiLUB), LB = mean(100-pcttpsdomiLUB-pcttpsSLUB), domi = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB), others = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB-pcttpsdomi) )
#
# timerep %>% ggplot(aes(x=n)) + geom_area( aes(y = additional_domi , fill = "Additional dominance tests for LUBs")) + geom_area( aes(y = SLUB , fill = "Computation of SLUBs")) + geom_area( aes(y = LB , fill = "LB set")) + geom_area( aes(y = domi , fill = "Dominance test")) + geom_area(aes(y = others , fill = "Others")) + xlab("Number of variables") + ylab("% of computational time") + ggtitle("Exact objective branching")
# ```
#
# Relative CPU time of the main components of the branch and bound in function of the number of variable for the branch and bound with the conic objective branching. The category "Others" include variable selection, node selection, creation of nodes and other implementation related details.
#
# ```{r,echo=FALSE}
# timerep <- filter(temp,pb=="FLe",OB=="cone") %>%
#   group_by(OB,n) %>%
#     summarize(additional_domi = 100, SLUB = mean(100-pcttpsdomiLUB), LB = mean(100-pcttpsdomiLUB-pcttpsSLUB), domi = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB), others = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB-pcttpsdomi) )
#
# timerep %>% ggplot(aes(x=n)) + geom_area( aes(y = additional_domi , fill = "Additional dominance tests for LUBs")) + geom_area( aes(y = SLUB , fill = "Computation of SLUBs")) + geom_area( aes(y = LB , fill = "LB set")) + geom_area( aes(y = domi , fill = "Dominance test")) + geom_area(aes(y = others , fill = "Others")) + xlab("Number of variables") + ylab("% of computational time") + ggtitle("Cone objective branching")
# ```
#
# #### Facility location hard
#
# Proportion of unsolved instances for each objective branching strategy in function of the number of variables for tri-objective Assignment problems.
#
# ```{r,echo=FALSE}
# t <- filter(temp,pb=="FLh") %>% group_by(OB,n) %>% count(solved==1)
# t <- mutate(t,norm = 100*nn/3)
# t %>%
#   ggplot(aes(x=n, y=norm, group=OB, color=OB)) + geom_line() + xlab("number of variables") + ylab("number of instances solved") + ggtitle("Percentage of tri-objective Assignment problem instances solved") + ylim(0,100)
# ```
#
# Relative CPU time of the main components of the branch and bound in function of the number of variable for the branch and bound without objective branching. The category "Others" include variable selection, node selection, creation of nodes and other implementation related details.
#
# ```{r,echo=FALSE}
# # time repartition stat
#
# timerep <- filter(temp,pb=="FLh",OB=="None") %>%
#   group_by(OB,n) %>%
#     summarize(additional_domi = 100, SLUB = mean(100-pcttpsdomiLUB), LB = mean(100-pcttpsdomiLUB-pcttpsSLUB), domi = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB), others = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB-pcttpsdomi) )
#
# timerep %>% ggplot(aes(x=n)) + geom_area( aes(y = additional_domi , fill = "Additional dominance tests for LUBs")) + geom_area( aes(y = SLUB , fill = "Computation of SLUBs")) + geom_area( aes(y = LB , fill = "LB set")) + geom_area( aes(y = domi , fill = "Dominance test")) + geom_area(aes(y = others , fill = "Others")) + xlab("Number of variables") + ylab("% of computational time") + ggtitle("No objective branching")
# ```
#
# Relative CPU time of the main components of the branch and bound in function of the number of variable for the branch and bound with exact objective branching. The category "Others" include variable selection, node selection, creation of nodes and other implementation related details.
#
# ```{r,echo=FALSE}
# timerep <- filter(temp,pb=="FLh",OB=="exact") %>%
#   group_by(OB,n) %>%
#     summarize(additional_domi = 100, SLUB = mean(100-pcttpsdomiLUB), LB = mean(100-pcttpsdomiLUB-pcttpsSLUB), domi = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB), others = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB-pcttpsdomi) )
#
# timerep %>% ggplot(aes(x=n)) + geom_area( aes(y = additional_domi , fill = "Additional dominance tests for LUBs")) + geom_area( aes(y = SLUB , fill = "Computation of SLUBs")) + geom_area( aes(y = LB , fill = "LB set")) + geom_area( aes(y = domi , fill = "Dominance test")) + geom_area(aes(y = others , fill = "Others")) + xlab("Number of variables") + ylab("% of computational time") + ggtitle("Exact objective branching")
# ```
#
# Relative CPU time of the main components of the branch and bound in function of the number of variable for the branch and bound with the conic objective branching. The category "Others" include variable selection, node selection, creation of nodes and other implementation related details.
#
# ```{r,echo=FALSE}
# timerep <- filter(temp,pb=="FLh",OB=="cone") %>%
#   group_by(OB,n) %>%
#     summarize(additional_domi = 100, SLUB = mean(100-pcttpsdomiLUB), LB = mean(100-pcttpsdomiLUB-pcttpsSLUB), domi = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB), others = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB-pcttpsdomi) )
#
# timerep %>% ggplot(aes(x=n)) + geom_area( aes(y = additional_domi , fill = "Additional dominance tests for LUBs")) + geom_area( aes(y = SLUB , fill = "Computation of SLUBs")) + geom_area( aes(y = LB , fill = "LB set")) + geom_area( aes(y = domi , fill = "Dominance test")) + geom_area(aes(y = others , fill = "Others")) + xlab("Number of variables") + ylab("% of computational time") + ggtitle("Cone objective branching")
# ```
#
#
#
#
#
# ### Range : [1000,2000]
#
# ```{r,echo=FALSE}
# temp <- filter(datOB,coef == "sphereup",rangemin == 1000,rangemax == 2000)
# tab <- filter(temp,solved == 1)
# tab <- temp %>%
#   group_by(pb,n,OB) %>%
#     summarize(avg = mean(tpstotal))
#
# pivot_wider(tab,names_from = OB, values_from = avg)
#
# st <- seq(0,4,by=0.5)
# val1 <- rep(0,length(st))
# t <- filter(temp, OB=="None")
# for (i in 1:length(st)) {
#   bidouille <- count(t,tpstotal <= st[i])
#   bidouille <- filter(bidouille,bidouille[1]!=FALSE)
#   if (count(bidouille) == 0) {
#     numer <- 0
#   }
#   else{
#     numer <- bidouille[[1,2]]
#   }
#   val1[i] <- 100*numer/count(t)[[1]]
# }
# val2 <- rep(0,length(st))
# t <- filter(temp, OB=="exact")
# for (i in 1:length(st)) {
#   bidouille <- count(t,tpstotal <= st[i])
#   bidouille <- filter(bidouille,bidouille[1]!=FALSE)
#   if (count(bidouille) == 0) {
#     numer <- 0
#   }
#   else{
#     numer <- bidouille[[1,2]]
#   }
#   val2[i] <- 100*numer/count(t)[[1]]
# }
# val3 <- rep(0,length(st))
# t <- filter(temp, OB=="cone")
# for (i in 1:length(st)) {
#   bidouille <- count(t,tpstotal <= st[i])
#   bidouille <- filter(bidouille,bidouille[1]!=FALSE)
#   if (count(bidouille) == 0) {
#     numer <- 0
#   }
#   else{
#     numer <- bidouille[[1,2]]
#   }
#   val3[i] <- 100*numer/count(t)[[1]]
# }
# pl <- tibble( step=st , perfBasic=val1, perfOB=val2, perfCone=val3)
# pl %>% ggplot( aes(x=step)) + geom_line(aes(y=perfBasic,colour="none")) + geom_line(aes(y=perfOB,colour="exact")) + geom_line(aes(y=perfCone,colour="cone")) + xlab("time (sec)") + ylab("% of solved instances") + ggtitle("Performance profile of objective branching")
#
# ```
#
# #### Knapsack
#
# Proportion of unsolved instances for each objective branching strategy in function of the number of variables for tri-objective Knapsack problems.
#
# ```{r,echo=FALSE}
# # unsolved stat
#
# t <- filter(temp,pb=="KP") %>% group_by(OB,n) %>% count(solved==1)
# t <- mutate(t,norm = 100*nn/3)
# t %>%
#   ggplot(aes(x=n, y=norm, group=OB, color=OB)) + geom_line() + xlab("number of variables") + ylab("% of instances solved") + ggtitle("Percentage of tri-objective Knapsack problem instances solved") + ylim(0,100)
# ```
#
# Relative CPU time of the main components of the branch and bound in function of the number of variable for the branch and bound without objective branching. The category "Others" include variable selection, node selection, creation of nodes and other implementation related details.
#
# ```{r,echo=FALSE}
# # time repartition stat
#
# timerep <- filter(temp,pb=="KP",OB=="None") %>%
#   group_by(OB,n) %>%
#     summarize(additional_domi = 100, SLUB = mean(100-pcttpsdomiLUB), LB = mean(100-pcttpsdomiLUB-pcttpsSLUB), domi = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB), others = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB-pcttpsdomi) )
#
# timerep %>% ggplot(aes(x=n)) + geom_area( aes(y = additional_domi , fill = "Additional dominance tests for LUBs")) + geom_area( aes(y = SLUB , fill = "Computation of SLUBs")) + geom_area( aes(y = LB , fill = "LB set")) + geom_area( aes(y = domi , fill = "Dominance test")) + geom_area(aes(y = others , fill = "Others")) + xlab("Number of variables") + ylab("% of computational time") + ggtitle("No objective branching")
# ```
#
# Relative CPU time of the main components of the branch and bound in function of the number of variable for the branch and bound with exact objective branching. The category "Others" include variable selection, node selection, creation of nodes and other implementation related details.
#
# ```{r,echo=FALSE}
# timerep <- filter(temp,pb=="KP",OB=="exact") %>%
#   group_by(OB,n) %>%
#     summarize(additional_domi = 100, SLUB = mean(100-pcttpsdomiLUB), LB = mean(100-pcttpsdomiLUB-pcttpsSLUB), domi = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB), others = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB-pcttpsdomi) )
#
# timerep %>% ggplot(aes(x=n)) + geom_area( aes(y = additional_domi , fill = "Additional dominance tests for LUBs")) + geom_area( aes(y = SLUB , fill = "Computation of SLUBs")) + geom_area( aes(y = LB , fill = "LB set")) + geom_area( aes(y = domi , fill = "Dominance test")) + geom_area(aes(y = others , fill = "Others")) + xlab("Number of variables") + ylab("% of computational time") + ggtitle("Exact objective branching")
# ```
#
# Relative CPU time of the main components of the branch and bound in function of the number of variable for the branch and bound with the conic objective branching. The category "Others" include variable selection, node selection, creation of nodes and other implementation related details.
#
# ```{r,echo=FALSE}
# timerep <- filter(temp,pb=="KP",OB=="cone") %>%
#   group_by(OB,n) %>%
#     summarize(additional_domi = 100, SLUB = mean(100-pcttpsdomiLUB), LB = mean(100-pcttpsdomiLUB-pcttpsSLUB), domi = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB), others = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB-pcttpsdomi) )
#
# timerep %>% ggplot(aes(x=n)) + geom_area( aes(y = additional_domi , fill = "Additional dominance tests for LUBs")) + geom_area( aes(y = SLUB , fill = "Computation of SLUBs")) + geom_area( aes(y = LB , fill = "LB set")) + geom_area( aes(y = domi , fill = "Dominance test")) + geom_area(aes(y = others , fill = "Others")) + xlab("Number of variables") + ylab("% of computational time") + ggtitle("Cone objective branching")
# ```
#
# #### Assignment
#
# Proportion of unsolved instances for each objective branching strategy in function of the number of variables for tri-objective Assignment problems.
#
# ```{r,echo=FALSE}
# t <- filter(temp,pb=="AS") %>% group_by(OB,n) %>% count(solved==1)
# t <- mutate(t,norm = 100*nn/3)
# t %>%
#   ggplot(aes(x=n, y=norm, group=OB, color=OB)) + geom_line() + xlab("number of variables") + ylab("number of instances solved") + ggtitle("Percentage of tri-objective Assignment problem instances solved") + ylim(0,100)
# ```
#
# Relative CPU time of the main components of the branch and bound in function of the number of variable for the branch and bound without objective branching. The category "Others" include variable selection, node selection, creation of nodes and other implementation related details.
#
# ```{r,echo=FALSE}
# # time repartition stat
#
# timerep <- filter(temp,pb=="AS",OB=="None") %>%
#   group_by(OB,n) %>%
#     summarize(additional_domi = 100, SLUB = mean(100-pcttpsdomiLUB), LB = mean(100-pcttpsdomiLUB-pcttpsSLUB), domi = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB), others = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB-pcttpsdomi) )
#
# timerep %>% ggplot(aes(x=n)) + geom_area( aes(y = additional_domi , fill = "Additional dominance tests for LUBs")) + geom_area( aes(y = SLUB , fill = "Computation of SLUBs")) + geom_area( aes(y = LB , fill = "LB set")) + geom_area( aes(y = domi , fill = "Dominance test")) + geom_area(aes(y = others , fill = "Others")) + xlab("Number of variables") + ylab("% of computational time") + ggtitle("No objective branching")
# ```
#
# Relative CPU time of the main components of the branch and bound in function of the number of variable for the branch and bound with exact objective branching. The category "Others" include variable selection, node selection, creation of nodes and other implementation related details.
#
# ```{r,echo=FALSE}
# timerep <- filter(temp,pb=="AS",OB=="exact") %>%
#   group_by(OB,n) %>%
#     summarize(additional_domi = 100, SLUB = mean(100-pcttpsdomiLUB), LB = mean(100-pcttpsdomiLUB-pcttpsSLUB), domi = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB), others = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB-pcttpsdomi) )
#
# timerep %>% ggplot(aes(x=n)) + geom_area( aes(y = additional_domi , fill = "Additional dominance tests for LUBs")) + geom_area( aes(y = SLUB , fill = "Computation of SLUBs")) + geom_area( aes(y = LB , fill = "LB set")) + geom_area( aes(y = domi , fill = "Dominance test")) + geom_area(aes(y = others , fill = "Others")) + xlab("Number of variables") + ylab("% of computational time") + ggtitle("Exact objective branching")
# ```
#
# Relative CPU time of the main components of the branch and bound in function of the number of variable for the branch and bound with the conic objective branching. The category "Others" include variable selection, node selection, creation of nodes and other implementation related details.
#
# ```{r,echo=FALSE}
# timerep <- filter(temp,pb=="AS",OB=="cone") %>%
#   group_by(OB,n) %>%
#     summarize(additional_domi = 100, SLUB = mean(100-pcttpsdomiLUB), LB = mean(100-pcttpsdomiLUB-pcttpsSLUB), domi = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB), others = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB-pcttpsdomi) )
#
# timerep %>% ggplot(aes(x=n)) + geom_area( aes(y = additional_domi , fill = "Additional dominance tests for LUBs")) + geom_area( aes(y = SLUB , fill = "Computation of SLUBs")) + geom_area( aes(y = LB , fill = "LB set")) + geom_area( aes(y = domi , fill = "Dominance test")) + geom_area(aes(y = others , fill = "Others")) + xlab("Number of variables") + ylab("% of computational time") + ggtitle("Cone objective branching")
# ```
#
# #### Facility location easy
#
# Proportion of unsolved instances for each objective branching strategy in function of the number of variables for tri-objective Assignment problems.
#
# ```{r,echo=FALSE}
# t <- filter(temp,pb=="FLe") %>% group_by(OB,n) %>% count(solved==1)
# t <- mutate(t,norm = 100*nn/3)
# t %>%
#   ggplot(aes(x=n, y=norm, group=OB, color=OB)) + geom_line() + xlab("number of variables") + ylab("number of instances solved") + ggtitle("Percentage of tri-objective Assignment problem instances solved") + ylim(0,100)
# ```
#
# Relative CPU time of the main components of the branch and bound in function of the number of variable for the branch and bound without objective branching. The category "Others" include variable selection, node selection, creation of nodes and other implementation related details.
#
# ```{r,echo=FALSE}
# # time repartition stat
#
# timerep <- filter(temp,pb=="FLe",OB=="None") %>%
#   group_by(OB,n) %>%
#     summarize(additional_domi = 100, SLUB = mean(100-pcttpsdomiLUB), LB = mean(100-pcttpsdomiLUB-pcttpsSLUB), domi = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB), others = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB-pcttpsdomi) )
#
# timerep %>% ggplot(aes(x=n)) + geom_area( aes(y = additional_domi , fill = "Additional dominance tests for LUBs")) + geom_area( aes(y = SLUB , fill = "Computation of SLUBs")) + geom_area( aes(y = LB , fill = "LB set")) + geom_area( aes(y = domi , fill = "Dominance test")) + geom_area(aes(y = others , fill = "Others")) + xlab("Number of variables") + ylab("% of computational time") + ggtitle("No objective branching")
# ```
#
# Relative CPU time of the main components of the branch and bound in function of the number of variable for the branch and bound with exact objective branching. The category "Others" include variable selection, node selection, creation of nodes and other implementation related details.
#
# ```{r,echo=FALSE}
# timerep <- filter(temp,pb=="FLe",OB=="exact") %>%
#   group_by(OB,n) %>%
#     summarize(additional_domi = 100, SLUB = mean(100-pcttpsdomiLUB), LB = mean(100-pcttpsdomiLUB-pcttpsSLUB), domi = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB), others = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB-pcttpsdomi) )
#
# timerep %>% ggplot(aes(x=n)) + geom_area( aes(y = additional_domi , fill = "Additional dominance tests for LUBs")) + geom_area( aes(y = SLUB , fill = "Computation of SLUBs")) + geom_area( aes(y = LB , fill = "LB set")) + geom_area( aes(y = domi , fill = "Dominance test")) + geom_area(aes(y = others , fill = "Others")) + xlab("Number of variables") + ylab("% of computational time") + ggtitle("Exact objective branching")
# ```
#
# Relative CPU time of the main components of the branch and bound in function of the number of variable for the branch and bound with the conic objective branching. The category "Others" include variable selection, node selection, creation of nodes and other implementation related details.
#
# ```{r,echo=FALSE}
# timerep <- filter(temp,pb=="FLe",OB=="cone") %>%
#   group_by(OB,n) %>%
#     summarize(additional_domi = 100, SLUB = mean(100-pcttpsdomiLUB), LB = mean(100-pcttpsdomiLUB-pcttpsSLUB), domi = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB), others = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB-pcttpsdomi) )
#
# timerep %>% ggplot(aes(x=n)) + geom_area( aes(y = additional_domi , fill = "Additional dominance tests for LUBs")) + geom_area( aes(y = SLUB , fill = "Computation of SLUBs")) + geom_area( aes(y = LB , fill = "LB set")) + geom_area( aes(y = domi , fill = "Dominance test")) + geom_area(aes(y = others , fill = "Others")) + xlab("Number of variables") + ylab("% of computational time") + ggtitle("Cone objective branching")
# ```
#
# #### Facility location hard
#
# Proportion of unsolved instances for each objective branching strategy in function of the number of variables for tri-objective Assignment problems.
#
# ```{r,echo=FALSE}
# t <- filter(temp,pb=="FLh") %>% group_by(OB,n) %>% count(solved==1)
# t <- mutate(t,norm = 100*nn/3)
# t %>%
#   ggplot(aes(x=n, y=norm, group=OB, color=OB)) + geom_line() + xlab("number of variables") + ylab("number of instances solved") + ggtitle("Percentage of tri-objective Assignment problem instances solved") + ylim(0,100)
# ```
#
# Relative CPU time of the main components of the branch and bound in function of the number of variable for the branch and bound without objective branching. The category "Others" include variable selection, node selection, creation of nodes and other implementation related details.
#
# ```{r,echo=FALSE}
# # time repartition stat
#
# timerep <- filter(temp,pb=="FLh",OB=="None") %>%
#   group_by(OB,n) %>%
#     summarize(additional_domi = 100, SLUB = mean(100-pcttpsdomiLUB), LB = mean(100-pcttpsdomiLUB-pcttpsSLUB), domi = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB), others = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB-pcttpsdomi) )
#
# timerep %>% ggplot(aes(x=n)) + geom_area( aes(y = additional_domi , fill = "Additional dominance tests for LUBs")) + geom_area( aes(y = SLUB , fill = "Computation of SLUBs")) + geom_area( aes(y = LB , fill = "LB set")) + geom_area( aes(y = domi , fill = "Dominance test")) + geom_area(aes(y = others , fill = "Others")) + xlab("Number of variables") + ylab("% of computational time") + ggtitle("No objective branching")
# ```
#
# Relative CPU time of the main components of the branch and bound in function of the number of variable for the branch and bound with exact objective branching. The category "Others" include variable selection, node selection, creation of nodes and other implementation related details.
#
# ```{r,echo=FALSE}
# timerep <- filter(temp,pb=="FLh",OB=="exact") %>%
#   group_by(OB,n) %>%
#     summarize(additional_domi = 100, SLUB = mean(100-pcttpsdomiLUB), LB = mean(100-pcttpsdomiLUB-pcttpsSLUB), domi = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB), others = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB-pcttpsdomi) )
#
# timerep %>% ggplot(aes(x=n)) + geom_area( aes(y = additional_domi , fill = "Additional dominance tests for LUBs")) + geom_area( aes(y = SLUB , fill = "Computation of SLUBs")) + geom_area( aes(y = LB , fill = "LB set")) + geom_area( aes(y = domi , fill = "Dominance test")) + geom_area(aes(y = others , fill = "Others")) + xlab("Number of variables") + ylab("% of computational time") + ggtitle("Exact objective branching")
# ```
#
# Relative CPU time of the main components of the branch and bound in function of the number of variable for the branch and bound with the conic objective branching. The category "Others" include variable selection, node selection, creation of nodes and other implementation related details.
#
# ```{r,echo=FALSE}
# timerep <- filter(temp,pb=="FLh",OB=="cone") %>%
#   group_by(OB,n) %>%
#     summarize(additional_domi = 100, SLUB = mean(100-pcttpsdomiLUB), LB = mean(100-pcttpsdomiLUB-pcttpsSLUB), domi = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB), others = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB-pcttpsdomi) )
#
# timerep %>% ggplot(aes(x=n)) + geom_area( aes(y = additional_domi , fill = "Additional dominance tests for LUBs")) + geom_area( aes(y = SLUB , fill = "Computation of SLUBs")) + geom_area( aes(y = LB , fill = "LB set")) + geom_area( aes(y = domi , fill = "Dominance test")) + geom_area(aes(y = others , fill = "Others")) + xlab("Number of variables") + ylab("% of computational time") + ggtitle("Cone objective branching")
# ```
#
#
#
#
#
# ## Two non-dominated boxes
#
# ### Range : [1,10]
#
# ```{r,echo=FALSE}
# temp <- filter(datOB,coef == "2box",rangemin == 1,rangemax == 10)
# tab <- filter(temp,solved == 1)
# tab <- temp %>%
#   group_by(pb,n,OB) %>%
#     summarize(avg = mean(tpstotal))
#
# pivot_wider(tab,names_from = OB, values_from = avg)
#
# st <- seq(0,4,by=0.5)
# val1 <- rep(0,length(st))
# t <- filter(temp, OB=="None")
# for (i in 1:length(st)) {
#   bidouille <- count(t,tpstotal <= st[i])
#   bidouille <- filter(bidouille,bidouille[1]!=FALSE)
#   if (count(bidouille) == 0) {
#     numer <- 0
#   }
#   else{
#     numer <- bidouille[[1,2]]
#   }
#   val1[i] <- 100*numer/count(t)[[1]]
# }
# val2 <- rep(0,length(st))
# t <- filter(temp, OB=="exact")
# for (i in 1:length(st)) {
#   bidouille <- count(t,tpstotal <= st[i])
#   bidouille <- filter(bidouille,bidouille[1]!=FALSE)
#   if (count(bidouille) == 0) {
#     numer <- 0
#   }
#   else{
#     numer <- bidouille[[1,2]]
#   }
#   val2[i] <- 100*numer/count(t)[[1]]
# }
# val3 <- rep(0,length(st))
# t <- filter(temp, OB=="cone")
# for (i in 1:length(st)) {
#   bidouille <- count(t,tpstotal <= st[i])
#   bidouille <- filter(bidouille,bidouille[1]!=FALSE)
#   if (count(bidouille) == 0) {
#     numer <- 0
#   }
#   else{
#     numer <- bidouille[[1,2]]
#   }
#   val3[i] <- 100*numer/count(t)[[1]]
# }
# pl <- tibble( step=st , perfBasic=val1, perfOB=val2, perfCone=val3)
# pl %>% ggplot( aes(x=step)) + geom_line(aes(y=perfBasic,colour="none")) + geom_line(aes(y=perfOB,colour="exact")) + geom_line(aes(y=perfCone,colour="cone")) + xlab("time (sec)") + ylab("% of solved instances") + ggtitle("Performance profile of objective branching")
#
# ```
#
# #### Knapsack
#
# Proportion of unsolved instances for each objective branching strategy in function of the number of variables for tri-objective Knapsack problems.
#
# ```{r,echo=FALSE}
# # unsolved stat
#
# t <- filter(temp,pb=="KP") %>% group_by(OB,n) %>% count(solved==1)
# t <- mutate(t,norm = 100*nn/3)
# t %>%
#   ggplot(aes(x=n, y=norm, group=OB, color=OB)) + geom_line() + xlab("number of variables") + ylab("% of instances solved") + ggtitle("Percentage of tri-objective Knapsack problem instances solved") + ylim(0,100)
# ```
#
# Relative CPU time of the main components of the branch and bound in function of the number of variable for the branch and bound without objective branching. The category "Others" include variable selection, node selection, creation of nodes and other implementation related details.
#
# ```{r,echo=FALSE}
# # time repartition stat
#
# timerep <- filter(temp,pb=="KP",OB=="None") %>%
#   group_by(OB,n) %>%
#     summarize(additional_domi = 100, SLUB = mean(100-pcttpsdomiLUB), LB = mean(100-pcttpsdomiLUB-pcttpsSLUB), domi = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB), others = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB-pcttpsdomi) )
#
# timerep %>% ggplot(aes(x=n)) + geom_area( aes(y = additional_domi , fill = "Additional dominance tests for LUBs")) + geom_area( aes(y = SLUB , fill = "Computation of SLUBs")) + geom_area( aes(y = LB , fill = "LB set")) + geom_area( aes(y = domi , fill = "Dominance test")) + geom_area(aes(y = others , fill = "Others")) + xlab("Number of variables") + ylab("% of computational time") + ggtitle("No objective branching")
# ```
#
# Relative CPU time of the main components of the branch and bound in function of the number of variable for the branch and bound with exact objective branching. The category "Others" include variable selection, node selection, creation of nodes and other implementation related details.
#
# ```{r,echo=FALSE}
# timerep <- filter(temp,pb=="KP",OB=="exact") %>%
#   group_by(OB,n) %>%
#     summarize(additional_domi = 100, SLUB = mean(100-pcttpsdomiLUB), LB = mean(100-pcttpsdomiLUB-pcttpsSLUB), domi = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB), others = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB-pcttpsdomi) )
#
# timerep %>% ggplot(aes(x=n)) + geom_area( aes(y = additional_domi , fill = "Additional dominance tests for LUBs")) + geom_area( aes(y = SLUB , fill = "Computation of SLUBs")) + geom_area( aes(y = LB , fill = "LB set")) + geom_area( aes(y = domi , fill = "Dominance test")) + geom_area(aes(y = others , fill = "Others")) + xlab("Number of variables") + ylab("% of computational time") + ggtitle("Exact objective branching")
# ```
#
# Relative CPU time of the main components of the branch and bound in function of the number of variable for the branch and bound with the conic objective branching. The category "Others" include variable selection, node selection, creation of nodes and other implementation related details.
#
# ```{r,echo=FALSE}
# timerep <- filter(temp,pb=="KP",OB=="cone") %>%
#   group_by(OB,n) %>%
#     summarize(additional_domi = 100, SLUB = mean(100-pcttpsdomiLUB), LB = mean(100-pcttpsdomiLUB-pcttpsSLUB), domi = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB), others = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB-pcttpsdomi) )
#
# timerep %>% ggplot(aes(x=n)) + geom_area( aes(y = additional_domi , fill = "Additional dominance tests for LUBs")) + geom_area( aes(y = SLUB , fill = "Computation of SLUBs")) + geom_area( aes(y = LB , fill = "LB set")) + geom_area( aes(y = domi , fill = "Dominance test")) + geom_area(aes(y = others , fill = "Others")) + xlab("Number of variables") + ylab("% of computational time") + ggtitle("Cone objective branching")
# ```
#
# #### Assignment
#
# Proportion of unsolved instances for each objective branching strategy in function of the number of variables for tri-objective Assignment problems.
#
# ```{r,echo=FALSE}
# t <- filter(temp,pb=="AS") %>% group_by(OB,n) %>% count(solved==1)
# t <- mutate(t,norm = 100*nn/3)
# t %>%
#   ggplot(aes(x=n, y=norm, group=OB, color=OB)) + geom_line() + xlab("number of variables") + ylab("number of instances solved") + ggtitle("Percentage of tri-objective Assignment problem instances solved") + ylim(0,100)
# ```
#
# Relative CPU time of the main components of the branch and bound in function of the number of variable for the branch and bound without objective branching. The category "Others" include variable selection, node selection, creation of nodes and other implementation related details.
#
# ```{r,echo=FALSE}
# # time repartition stat
#
# timerep <- filter(temp,pb=="AS",OB=="None") %>%
#   group_by(OB,n) %>%
#     summarize(additional_domi = 100, SLUB = mean(100-pcttpsdomiLUB), LB = mean(100-pcttpsdomiLUB-pcttpsSLUB), domi = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB), others = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB-pcttpsdomi) )
#
# timerep %>% ggplot(aes(x=n)) + geom_area( aes(y = additional_domi , fill = "Additional dominance tests for LUBs")) + geom_area( aes(y = SLUB , fill = "Computation of SLUBs")) + geom_area( aes(y = LB , fill = "LB set")) + geom_area( aes(y = domi , fill = "Dominance test")) + geom_area(aes(y = others , fill = "Others")) + xlab("Number of variables") + ylab("% of computational time") + ggtitle("No objective branching")
# ```
#
# Relative CPU time of the main components of the branch and bound in function of the number of variable for the branch and bound with exact objective branching. The category "Others" include variable selection, node selection, creation of nodes and other implementation related details.
#
# ```{r,echo=FALSE}
# timerep <- filter(temp,pb=="AS",OB=="exact") %>%
#   group_by(OB,n) %>%
#     summarize(additional_domi = 100, SLUB = mean(100-pcttpsdomiLUB), LB = mean(100-pcttpsdomiLUB-pcttpsSLUB), domi = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB), others = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB-pcttpsdomi) )
#
# timerep %>% ggplot(aes(x=n)) + geom_area( aes(y = additional_domi , fill = "Additional dominance tests for LUBs")) + geom_area( aes(y = SLUB , fill = "Computation of SLUBs")) + geom_area( aes(y = LB , fill = "LB set")) + geom_area( aes(y = domi , fill = "Dominance test")) + geom_area(aes(y = others , fill = "Others")) + xlab("Number of variables") + ylab("% of computational time") + ggtitle("Exact objective branching")
# ```
#
# Relative CPU time of the main components of the branch and bound in function of the number of variable for the branch and bound with the conic objective branching. The category "Others" include variable selection, node selection, creation of nodes and other implementation related details.
#
# ```{r,echo=FALSE}
# timerep <- filter(temp,pb=="AS",OB=="cone") %>%
#   group_by(OB,n) %>%
#     summarize(additional_domi = 100, SLUB = mean(100-pcttpsdomiLUB), LB = mean(100-pcttpsdomiLUB-pcttpsSLUB), domi = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB), others = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB-pcttpsdomi) )
#
# timerep %>% ggplot(aes(x=n)) + geom_area( aes(y = additional_domi , fill = "Additional dominance tests for LUBs")) + geom_area( aes(y = SLUB , fill = "Computation of SLUBs")) + geom_area( aes(y = LB , fill = "LB set")) + geom_area( aes(y = domi , fill = "Dominance test")) + geom_area(aes(y = others , fill = "Others")) + xlab("Number of variables") + ylab("% of computational time") + ggtitle("Cone objective branching")
# ```
#
# #### Facility location easy
#
# Proportion of unsolved instances for each objective branching strategy in function of the number of variables for tri-objective Assignment problems.
#
# ```{r,echo=FALSE}
# t <- filter(temp,pb=="FLe") %>% group_by(OB,n) %>% count(solved==1)
# t <- mutate(t,norm = 100*nn/3)
# t %>%
#   ggplot(aes(x=n, y=norm, group=OB, color=OB)) + geom_line() + xlab("number of variables") + ylab("number of instances solved") + ggtitle("Percentage of tri-objective Assignment problem instances solved") + ylim(0,100)
# ```
#
# Relative CPU time of the main components of the branch and bound in function of the number of variable for the branch and bound without objective branching. The category "Others" include variable selection, node selection, creation of nodes and other implementation related details.
#
# ```{r,echo=FALSE}
# # time repartition stat
#
# timerep <- filter(temp,pb=="FLe",OB=="None") %>%
#   group_by(OB,n) %>%
#     summarize(additional_domi = 100, SLUB = mean(100-pcttpsdomiLUB), LB = mean(100-pcttpsdomiLUB-pcttpsSLUB), domi = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB), others = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB-pcttpsdomi) )
#
# timerep %>% ggplot(aes(x=n)) + geom_area( aes(y = additional_domi , fill = "Additional dominance tests for LUBs")) + geom_area( aes(y = SLUB , fill = "Computation of SLUBs")) + geom_area( aes(y = LB , fill = "LB set")) + geom_area( aes(y = domi , fill = "Dominance test")) + geom_area(aes(y = others , fill = "Others")) + xlab("Number of variables") + ylab("% of computational time") + ggtitle("No objective branching")
# ```
#
# Relative CPU time of the main components of the branch and bound in function of the number of variable for the branch and bound with exact objective branching. The category "Others" include variable selection, node selection, creation of nodes and other implementation related details.
#
# ```{r,echo=FALSE}
# timerep <- filter(temp,pb=="FLe",OB=="exact") %>%
#   group_by(OB,n) %>%
#     summarize(additional_domi = 100, SLUB = mean(100-pcttpsdomiLUB), LB = mean(100-pcttpsdomiLUB-pcttpsSLUB), domi = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB), others = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB-pcttpsdomi) )
#
# timerep %>% ggplot(aes(x=n)) + geom_area( aes(y = additional_domi , fill = "Additional dominance tests for LUBs")) + geom_area( aes(y = SLUB , fill = "Computation of SLUBs")) + geom_area( aes(y = LB , fill = "LB set")) + geom_area( aes(y = domi , fill = "Dominance test")) + geom_area(aes(y = others , fill = "Others")) + xlab("Number of variables") + ylab("% of computational time") + ggtitle("Exact objective branching")
# ```
#
# Relative CPU time of the main components of the branch and bound in function of the number of variable for the branch and bound with the conic objective branching. The category "Others" include variable selection, node selection, creation of nodes and other implementation related details.
#
# ```{r,echo=FALSE}
# timerep <- filter(temp,pb=="FLe",OB=="cone") %>%
#   group_by(OB,n) %>%
#     summarize(additional_domi = 100, SLUB = mean(100-pcttpsdomiLUB), LB = mean(100-pcttpsdomiLUB-pcttpsSLUB), domi = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB), others = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB-pcttpsdomi) )
#
# timerep %>% ggplot(aes(x=n)) + geom_area( aes(y = additional_domi , fill = "Additional dominance tests for LUBs")) + geom_area( aes(y = SLUB , fill = "Computation of SLUBs")) + geom_area( aes(y = LB , fill = "LB set")) + geom_area( aes(y = domi , fill = "Dominance test")) + geom_area(aes(y = others , fill = "Others")) + xlab("Number of variables") + ylab("% of computational time") + ggtitle("Cone objective branching")
# ```
#
# #### Facility location hard
#
# Proportion of unsolved instances for each objective branching strategy in function of the number of variables for tri-objective Assignment problems.
#
# ```{r,echo=FALSE}
# t <- filter(temp,pb=="FLh") %>% group_by(OB,n) %>% count(solved==1)
# t <- mutate(t,norm = 100*nn/3)
# t %>%
#   ggplot(aes(x=n, y=norm, group=OB, color=OB)) + geom_line() + xlab("number of variables") + ylab("number of instances solved") + ggtitle("Percentage of tri-objective Assignment problem instances solved") + ylim(0,100)
# ```
#
# Relative CPU time of the main components of the branch and bound in function of the number of variable for the branch and bound without objective branching. The category "Others" include variable selection, node selection, creation of nodes and other implementation related details.
#
# ```{r,echo=FALSE}
# # time repartition stat
#
# timerep <- filter(temp,pb=="FLh",OB=="None") %>%
#   group_by(OB,n) %>%
#     summarize(additional_domi = 100, SLUB = mean(100-pcttpsdomiLUB), LB = mean(100-pcttpsdomiLUB-pcttpsSLUB), domi = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB), others = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB-pcttpsdomi) )
#
# timerep %>% ggplot(aes(x=n)) + geom_area( aes(y = additional_domi , fill = "Additional dominance tests for LUBs")) + geom_area( aes(y = SLUB , fill = "Computation of SLUBs")) + geom_area( aes(y = LB , fill = "LB set")) + geom_area( aes(y = domi , fill = "Dominance test")) + geom_area(aes(y = others , fill = "Others")) + xlab("Number of variables") + ylab("% of computational time") + ggtitle("No objective branching")
# ```
#
# Relative CPU time of the main components of the branch and bound in function of the number of variable for the branch and bound with exact objective branching. The category "Others" include variable selection, node selection, creation of nodes and other implementation related details.
#
# ```{r,echo=FALSE}
# timerep <- filter(temp,pb=="FLh",OB=="exact") %>%
#   group_by(OB,n) %>%
#     summarize(additional_domi = 100, SLUB = mean(100-pcttpsdomiLUB), LB = mean(100-pcttpsdomiLUB-pcttpsSLUB), domi = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB), others = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB-pcttpsdomi) )
#
# timerep %>% ggplot(aes(x=n)) + geom_area( aes(y = additional_domi , fill = "Additional dominance tests for LUBs")) + geom_area( aes(y = SLUB , fill = "Computation of SLUBs")) + geom_area( aes(y = LB , fill = "LB set")) + geom_area( aes(y = domi , fill = "Dominance test")) + geom_area(aes(y = others , fill = "Others")) + xlab("Number of variables") + ylab("% of computational time") + ggtitle("Exact objective branching")
# ```
#
# Relative CPU time of the main components of the branch and bound in function of the number of variable for the branch and bound with the conic objective branching. The category "Others" include variable selection, node selection, creation of nodes and other implementation related details.
#
# ```{r,echo=FALSE}
# timerep <- filter(temp,pb=="FLh",OB=="cone") %>%
#   group_by(OB,n) %>%
#     summarize(additional_domi = 100, SLUB = mean(100-pcttpsdomiLUB), LB = mean(100-pcttpsdomiLUB-pcttpsSLUB), domi = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB), others = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB-pcttpsdomi) )
#
# timerep %>% ggplot(aes(x=n)) + geom_area( aes(y = additional_domi , fill = "Additional dominance tests for LUBs")) + geom_area( aes(y = SLUB , fill = "Computation of SLUBs")) + geom_area( aes(y = LB , fill = "LB set")) + geom_area( aes(y = domi , fill = "Dominance test")) + geom_area(aes(y = others , fill = "Others")) + xlab("Number of variables") + ylab("% of computational time") + ggtitle("Cone objective branching")
# ```
#
#
# ### Range : [1,1000]
#
# ```{r,echo=FALSE}
# temp <- filter(datOB,coef == "2box",rangemin == 1,rangemax == 1000)
# tab <- filter(temp,solved == 1)
# tab <- temp %>%
#   group_by(pb,n,OB) %>%
#     summarize(avg = mean(tpstotal))
#
# pivot_wider(tab,names_from = OB, values_from = avg)
#
# st <- seq(0,4,by=0.5)
# val1 <- rep(0,length(st))
# t <- filter(temp, OB=="None")
# for (i in 1:length(st)) {
#   bidouille <- count(t,tpstotal <= st[i])
#   bidouille <- filter(bidouille,bidouille[1]!=FALSE)
#   if (count(bidouille) == 0) {
#     numer <- 0
#   }
#   else{
#     numer <- bidouille[[1,2]]
#   }
#   val1[i] <- 100*numer/count(t)[[1]]
# }
# val2 <- rep(0,length(st))
# t <- filter(temp, OB=="exact")
# for (i in 1:length(st)) {
#   bidouille <- count(t,tpstotal <= st[i])
#   bidouille <- filter(bidouille,bidouille[1]!=FALSE)
#   if (count(bidouille) == 0) {
#     numer <- 0
#   }
#   else{
#     numer <- bidouille[[1,2]]
#   }
#   val2[i] <- 100*numer/count(t)[[1]]
# }
# val3 <- rep(0,length(st))
# t <- filter(temp, OB=="cone")
# for (i in 1:length(st)) {
#   bidouille <- count(t,tpstotal <= st[i])
#   bidouille <- filter(bidouille,bidouille[1]!=FALSE)
#   if (count(bidouille) == 0) {
#     numer <- 0
#   }
#   else{
#     numer <- bidouille[[1,2]]
#   }
#   val3[i] <- 100*numer/count(t)[[1]]
# }
# pl <- tibble( step=st , perfBasic=val1, perfOB=val2, perfCone=val3)
# pl %>% ggplot( aes(x=step)) + geom_line(aes(y=perfBasic,colour="none")) + geom_line(aes(y=perfOB,colour="exact")) + geom_line(aes(y=perfCone,colour="cone")) + xlab("time (sec)") + ylab("% of solved instances") + ggtitle("Performance profile of objective branching")
#
# ```
#
# #### Knapsack
#
# Proportion of unsolved instances for each objective branching strategy in function of the number of variables for tri-objective Knapsack problems.
#
# ```{r,echo=FALSE}
# # unsolved stat
#
# t <- filter(temp,pb=="KP") %>% group_by(OB,n) %>% count(solved==1)
# t <- mutate(t,norm = 100*nn/3)
# t %>%
#   ggplot(aes(x=n, y=norm, group=OB, color=OB)) + geom_line() + xlab("number of variables") + ylab("% of instances solved") + ggtitle("Percentage of tri-objective Knapsack problem instances solved") + ylim(0,100)
# ```
#
# Relative CPU time of the main components of the branch and bound in function of the number of variable for the branch and bound without objective branching. The category "Others" include variable selection, node selection, creation of nodes and other implementation related details.
#
# ```{r,echo=FALSE}
# # time repartition stat
#
# timerep <- filter(temp,pb=="KP",OB=="None") %>%
#   group_by(OB,n) %>%
#     summarize(additional_domi = 100, SLUB = mean(100-pcttpsdomiLUB), LB = mean(100-pcttpsdomiLUB-pcttpsSLUB), domi = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB), others = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB-pcttpsdomi) )
#
# timerep %>% ggplot(aes(x=n)) + geom_area( aes(y = additional_domi , fill = "Additional dominance tests for LUBs")) + geom_area( aes(y = SLUB , fill = "Computation of SLUBs")) + geom_area( aes(y = LB , fill = "LB set")) + geom_area( aes(y = domi , fill = "Dominance test")) + geom_area(aes(y = others , fill = "Others")) + xlab("Number of variables") + ylab("% of computational time") + ggtitle("No objective branching")
# ```
#
# Relative CPU time of the main components of the branch and bound in function of the number of variable for the branch and bound with exact objective branching. The category "Others" include variable selection, node selection, creation of nodes and other implementation related details.
#
# ```{r,echo=FALSE}
# timerep <- filter(temp,pb=="KP",OB=="exact") %>%
#   group_by(OB,n) %>%
#     summarize(additional_domi = 100, SLUB = mean(100-pcttpsdomiLUB), LB = mean(100-pcttpsdomiLUB-pcttpsSLUB), domi = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB), others = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB-pcttpsdomi) )
#
# timerep %>% ggplot(aes(x=n)) + geom_area( aes(y = additional_domi , fill = "Additional dominance tests for LUBs")) + geom_area( aes(y = SLUB , fill = "Computation of SLUBs")) + geom_area( aes(y = LB , fill = "LB set")) + geom_area( aes(y = domi , fill = "Dominance test")) + geom_area(aes(y = others , fill = "Others")) + xlab("Number of variables") + ylab("% of computational time") + ggtitle("Exact objective branching")
# ```
#
# Relative CPU time of the main components of the branch and bound in function of the number of variable for the branch and bound with the conic objective branching. The category "Others" include variable selection, node selection, creation of nodes and other implementation related details.
#
# ```{r,echo=FALSE}
# timerep <- filter(temp,pb=="KP",OB=="cone") %>%
#   group_by(OB,n) %>%
#     summarize(additional_domi = 100, SLUB = mean(100-pcttpsdomiLUB), LB = mean(100-pcttpsdomiLUB-pcttpsSLUB), domi = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB), others = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB-pcttpsdomi) )
#
# timerep %>% ggplot(aes(x=n)) + geom_area( aes(y = additional_domi , fill = "Additional dominance tests for LUBs")) + geom_area( aes(y = SLUB , fill = "Computation of SLUBs")) + geom_area( aes(y = LB , fill = "LB set")) + geom_area( aes(y = domi , fill = "Dominance test")) + geom_area(aes(y = others , fill = "Others")) + xlab("Number of variables") + ylab("% of computational time") + ggtitle("Cone objective branching")
# ```
#
# #### Assignment
#
# Proportion of unsolved instances for each objective branching strategy in function of the number of variables for tri-objective Assignment problems.
#
# ```{r,echo=FALSE}
# t <- filter(temp,pb=="AS") %>% group_by(OB,n) %>% count(solved==1)
# t <- mutate(t,norm = 100*nn/3)
# t %>%
#   ggplot(aes(x=n, y=norm, group=OB, color=OB)) + geom_line() + xlab("number of variables") + ylab("number of instances solved") + ggtitle("Percentage of tri-objective Assignment problem instances solved") + ylim(0,100)
# ```
#
# Relative CPU time of the main components of the branch and bound in function of the number of variable for the branch and bound without objective branching. The category "Others" include variable selection, node selection, creation of nodes and other implementation related details.
#
# ```{r,echo=FALSE}
# # time repartition stat
#
# timerep <- filter(temp,pb=="AS",OB=="None") %>%
#   group_by(OB,n) %>%
#     summarize(additional_domi = 100, SLUB = mean(100-pcttpsdomiLUB), LB = mean(100-pcttpsdomiLUB-pcttpsSLUB), domi = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB), others = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB-pcttpsdomi) )
#
# timerep %>% ggplot(aes(x=n)) + geom_area( aes(y = additional_domi , fill = "Additional dominance tests for LUBs")) + geom_area( aes(y = SLUB , fill = "Computation of SLUBs")) + geom_area( aes(y = LB , fill = "LB set")) + geom_area( aes(y = domi , fill = "Dominance test")) + geom_area(aes(y = others , fill = "Others")) + xlab("Number of variables") + ylab("% of computational time") + ggtitle("No objective branching")
# ```
#
# Relative CPU time of the main components of the branch and bound in function of the number of variable for the branch and bound with exact objective branching. The category "Others" include variable selection, node selection, creation of nodes and other implementation related details.
#
# ```{r,echo=FALSE}
# timerep <- filter(temp,pb=="AS",OB=="exact") %>%
#   group_by(OB,n) %>%
#     summarize(additional_domi = 100, SLUB = mean(100-pcttpsdomiLUB), LB = mean(100-pcttpsdomiLUB-pcttpsSLUB), domi = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB), others = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB-pcttpsdomi) )
#
# timerep %>% ggplot(aes(x=n)) + geom_area( aes(y = additional_domi , fill = "Additional dominance tests for LUBs")) + geom_area( aes(y = SLUB , fill = "Computation of SLUBs")) + geom_area( aes(y = LB , fill = "LB set")) + geom_area( aes(y = domi , fill = "Dominance test")) + geom_area(aes(y = others , fill = "Others")) + xlab("Number of variables") + ylab("% of computational time") + ggtitle("Exact objective branching")
# ```
#
# Relative CPU time of the main components of the branch and bound in function of the number of variable for the branch and bound with the conic objective branching. The category "Others" include variable selection, node selection, creation of nodes and other implementation related details.
#
# ```{r,echo=FALSE}
# timerep <- filter(temp,pb=="AS",OB=="cone") %>%
#   group_by(OB,n) %>%
#     summarize(additional_domi = 100, SLUB = mean(100-pcttpsdomiLUB), LB = mean(100-pcttpsdomiLUB-pcttpsSLUB), domi = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB), others = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB-pcttpsdomi) )
#
# timerep %>% ggplot(aes(x=n)) + geom_area( aes(y = additional_domi , fill = "Additional dominance tests for LUBs")) + geom_area( aes(y = SLUB , fill = "Computation of SLUBs")) + geom_area( aes(y = LB , fill = "LB set")) + geom_area( aes(y = domi , fill = "Dominance test")) + geom_area(aes(y = others , fill = "Others")) + xlab("Number of variables") + ylab("% of computational time") + ggtitle("Cone objective branching")
# ```
#
# #### Facility location easy
#
# Proportion of unsolved instances for each objective branching strategy in function of the number of variables for tri-objective Assignment problems.
#
# ```{r,echo=FALSE}
# t <- filter(temp,pb=="FLe") %>% group_by(OB,n) %>% count(solved==1)
# t <- mutate(t,norm = 100*nn/3)
# t %>%
#   ggplot(aes(x=n, y=norm, group=OB, color=OB)) + geom_line() + xlab("number of variables") + ylab("number of instances solved") + ggtitle("Percentage of tri-objective Assignment problem instances solved") + ylim(0,100)
# ```
#
# Relative CPU time of the main components of the branch and bound in function of the number of variable for the branch and bound without objective branching. The category "Others" include variable selection, node selection, creation of nodes and other implementation related details.
#
# ```{r,echo=FALSE}
# # time repartition stat
#
# timerep <- filter(temp,pb=="FLe",OB=="None") %>%
#   group_by(OB,n) %>%
#     summarize(additional_domi = 100, SLUB = mean(100-pcttpsdomiLUB), LB = mean(100-pcttpsdomiLUB-pcttpsSLUB), domi = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB), others = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB-pcttpsdomi) )
#
# timerep %>% ggplot(aes(x=n)) + geom_area( aes(y = additional_domi , fill = "Additional dominance tests for LUBs")) + geom_area( aes(y = SLUB , fill = "Computation of SLUBs")) + geom_area( aes(y = LB , fill = "LB set")) + geom_area( aes(y = domi , fill = "Dominance test")) + geom_area(aes(y = others , fill = "Others")) + xlab("Number of variables") + ylab("% of computational time") + ggtitle("No objective branching")
# ```
#
# Relative CPU time of the main components of the branch and bound in function of the number of variable for the branch and bound with exact objective branching. The category "Others" include variable selection, node selection, creation of nodes and other implementation related details.
#
# ```{r,echo=FALSE}
# timerep <- filter(temp,pb=="FLe",OB=="exact") %>%
#   group_by(OB,n) %>%
#     summarize(additional_domi = 100, SLUB = mean(100-pcttpsdomiLUB), LB = mean(100-pcttpsdomiLUB-pcttpsSLUB), domi = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB), others = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB-pcttpsdomi) )
#
# timerep %>% ggplot(aes(x=n)) + geom_area( aes(y = additional_domi , fill = "Additional dominance tests for LUBs")) + geom_area( aes(y = SLUB , fill = "Computation of SLUBs")) + geom_area( aes(y = LB , fill = "LB set")) + geom_area( aes(y = domi , fill = "Dominance test")) + geom_area(aes(y = others , fill = "Others")) + xlab("Number of variables") + ylab("% of computational time") + ggtitle("Exact objective branching")
# ```
#
# Relative CPU time of the main components of the branch and bound in function of the number of variable for the branch and bound with the conic objective branching. The category "Others" include variable selection, node selection, creation of nodes and other implementation related details.
#
# ```{r,echo=FALSE}
# timerep <- filter(temp,pb=="FLe",OB=="cone") %>%
#   group_by(OB,n) %>%
#     summarize(additional_domi = 100, SLUB = mean(100-pcttpsdomiLUB), LB = mean(100-pcttpsdomiLUB-pcttpsSLUB), domi = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB), others = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB-pcttpsdomi) )
#
# timerep %>% ggplot(aes(x=n)) + geom_area( aes(y = additional_domi , fill = "Additional dominance tests for LUBs")) + geom_area( aes(y = SLUB , fill = "Computation of SLUBs")) + geom_area( aes(y = LB , fill = "LB set")) + geom_area( aes(y = domi , fill = "Dominance test")) + geom_area(aes(y = others , fill = "Others")) + xlab("Number of variables") + ylab("% of computational time") + ggtitle("Cone objective branching")
# ```
#
# #### Facility location hard
#
# Proportion of unsolved instances for each objective branching strategy in function of the number of variables for tri-objective Assignment problems.
#
# ```{r,echo=FALSE}
# t <- filter(temp,pb=="FLh") %>% group_by(OB,n) %>% count(solved==1)
# t <- mutate(t,norm = 100*nn/3)
# t %>%
#   ggplot(aes(x=n, y=norm, group=OB, color=OB)) + geom_line() + xlab("number of variables") + ylab("number of instances solved") + ggtitle("Percentage of tri-objective Assignment problem instances solved") + ylim(0,100)
# ```
#
# Relative CPU time of the main components of the branch and bound in function of the number of variable for the branch and bound without objective branching. The category "Others" include variable selection, node selection, creation of nodes and other implementation related details.
#
# ```{r,echo=FALSE}
# # time repartition stat
#
# timerep <- filter(temp,pb=="FLh",OB=="None") %>%
#   group_by(OB,n) %>%
#     summarize(additional_domi = 100, SLUB = mean(100-pcttpsdomiLUB), LB = mean(100-pcttpsdomiLUB-pcttpsSLUB), domi = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB), others = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB-pcttpsdomi) )
#
# timerep %>% ggplot(aes(x=n)) + geom_area( aes(y = additional_domi , fill = "Additional dominance tests for LUBs")) + geom_area( aes(y = SLUB , fill = "Computation of SLUBs")) + geom_area( aes(y = LB , fill = "LB set")) + geom_area( aes(y = domi , fill = "Dominance test")) + geom_area(aes(y = others , fill = "Others")) + xlab("Number of variables") + ylab("% of computational time") + ggtitle("No objective branching")
# ```
#
# Relative CPU time of the main components of the branch and bound in function of the number of variable for the branch and bound with exact objective branching. The category "Others" include variable selection, node selection, creation of nodes and other implementation related details.
#
# ```{r,echo=FALSE}
# timerep <- filter(temp,pb=="FLh",OB=="exact") %>%
#   group_by(OB,n) %>%
#     summarize(additional_domi = 100, SLUB = mean(100-pcttpsdomiLUB), LB = mean(100-pcttpsdomiLUB-pcttpsSLUB), domi = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB), others = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB-pcttpsdomi) )
#
# timerep %>% ggplot(aes(x=n)) + geom_area( aes(y = additional_domi , fill = "Additional dominance tests for LUBs")) + geom_area( aes(y = SLUB , fill = "Computation of SLUBs")) + geom_area( aes(y = LB , fill = "LB set")) + geom_area( aes(y = domi , fill = "Dominance test")) + geom_area(aes(y = others , fill = "Others")) + xlab("Number of variables") + ylab("% of computational time") + ggtitle("Exact objective branching")
# ```
#
# Relative CPU time of the main components of the branch and bound in function of the number of variable for the branch and bound with the conic objective branching. The category "Others" include variable selection, node selection, creation of nodes and other implementation related details.
#
# ```{r,echo=FALSE}
# timerep <- filter(temp,pb=="FLh",OB=="cone") %>%
#   group_by(OB,n) %>%
#     summarize(additional_domi = 100, SLUB = mean(100-pcttpsdomiLUB), LB = mean(100-pcttpsdomiLUB-pcttpsSLUB), domi = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB), others = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB-pcttpsdomi) )
#
# timerep %>% ggplot(aes(x=n)) + geom_area( aes(y = additional_domi , fill = "Additional dominance tests for LUBs")) + geom_area( aes(y = SLUB , fill = "Computation of SLUBs")) + geom_area( aes(y = LB , fill = "LB set")) + geom_area( aes(y = domi , fill = "Dominance test")) + geom_area(aes(y = others , fill = "Others")) + xlab("Number of variables") + ylab("% of computational time") + ggtitle("Cone objective branching")
# ```
#
#
#
#
#
# ### Range : [1000,2000]
#
# ```{r,echo=FALSE}
# temp <- filter(datOB,coef == "2box",rangemin == 1000,rangemax == 2000)
# tab <- filter(temp,solved == 1)
# tab <- temp %>%
#   group_by(pb,n,OB) %>%
#     summarize(avg = mean(tpstotal))
#
# pivot_wider(tab,names_from = OB, values_from = avg)
#
# st <- seq(0,4,by=0.5)
# val1 <- rep(0,length(st))
# t <- filter(temp, OB=="None")
# for (i in 1:length(st)) {
#   bidouille <- count(t,tpstotal <= st[i])
#   bidouille <- filter(bidouille,bidouille[1]!=FALSE)
#   if (count(bidouille) == 0) {
#     numer <- 0
#   }
#   else{
#     numer <- bidouille[[1,2]]
#   }
#   val1[i] <- 100*numer/count(t)[[1]]
# }
# val2 <- rep(0,length(st))
# t <- filter(temp, OB=="exact")
# for (i in 1:length(st)) {
#   bidouille <- count(t,tpstotal <= st[i])
#   bidouille <- filter(bidouille,bidouille[1]!=FALSE)
#   if (count(bidouille) == 0) {
#     numer <- 0
#   }
#   else{
#     numer <- bidouille[[1,2]]
#   }
#   val2[i] <- 100*numer/count(t)[[1]]
# }
# val3 <- rep(0,length(st))
# t <- filter(temp, OB=="cone")
# for (i in 1:length(st)) {
#   bidouille <- count(t,tpstotal <= st[i])
#   bidouille <- filter(bidouille,bidouille[1]!=FALSE)
#   if (count(bidouille) == 0) {
#     numer <- 0
#   }
#   else{
#     numer <- bidouille[[1,2]]
#   }
#   val3[i] <- 100*numer/count(t)[[1]]
# }
# pl <- tibble( step=st , perfBasic=val1, perfOB=val2, perfCone=val3)
# pl %>% ggplot( aes(x=step)) + geom_line(aes(y=perfBasic,colour="none")) + geom_line(aes(y=perfOB,colour="exact")) + geom_line(aes(y=perfCone,colour="cone")) + xlab("time (sec)") + ylab("% of solved instances") + ggtitle("Performance profile of objective branching")
#
# ```
#
# #### Knapsack
#
# Proportion of unsolved instances for each objective branching strategy in function of the number of variables for tri-objective Knapsack problems.
#
# ```{r,echo=FALSE}
# # unsolved stat
#
# t <- filter(temp,pb=="KP") %>% group_by(OB,n) %>% count(solved==1)
# t <- mutate(t,norm = 100*nn/3)
# t %>%
#   ggplot(aes(x=n, y=norm, group=OB, color=OB)) + geom_line() + xlab("number of variables") + ylab("% of instances solved") + ggtitle("Percentage of tri-objective Knapsack problem instances solved") + ylim(0,100)
# ```
#
# Relative CPU time of the main components of the branch and bound in function of the number of variable for the branch and bound without objective branching. The category "Others" include variable selection, node selection, creation of nodes and other implementation related details.
#
# ```{r,echo=FALSE}
# # time repartition stat
#
# timerep <- filter(temp,pb=="KP",OB=="None") %>%
#   group_by(OB,n) %>%
#     summarize(additional_domi = 100, SLUB = mean(100-pcttpsdomiLUB), LB = mean(100-pcttpsdomiLUB-pcttpsSLUB), domi = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB), others = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB-pcttpsdomi) )
#
# timerep %>% ggplot(aes(x=n)) + geom_area( aes(y = additional_domi , fill = "Additional dominance tests for LUBs")) + geom_area( aes(y = SLUB , fill = "Computation of SLUBs")) + geom_area( aes(y = LB , fill = "LB set")) + geom_area( aes(y = domi , fill = "Dominance test")) + geom_area(aes(y = others , fill = "Others")) + xlab("Number of variables") + ylab("% of computational time") + ggtitle("No objective branching")
# ```
#
# Relative CPU time of the main components of the branch and bound in function of the number of variable for the branch and bound with exact objective branching. The category "Others" include variable selection, node selection, creation of nodes and other implementation related details.
#
# ```{r,echo=FALSE}
# timerep <- filter(temp,pb=="KP",OB=="exact") %>%
#   group_by(OB,n) %>%
#     summarize(additional_domi = 100, SLUB = mean(100-pcttpsdomiLUB), LB = mean(100-pcttpsdomiLUB-pcttpsSLUB), domi = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB), others = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB-pcttpsdomi) )
#
# timerep %>% ggplot(aes(x=n)) + geom_area( aes(y = additional_domi , fill = "Additional dominance tests for LUBs")) + geom_area( aes(y = SLUB , fill = "Computation of SLUBs")) + geom_area( aes(y = LB , fill = "LB set")) + geom_area( aes(y = domi , fill = "Dominance test")) + geom_area(aes(y = others , fill = "Others")) + xlab("Number of variables") + ylab("% of computational time") + ggtitle("Exact objective branching")
# ```
#
# Relative CPU time of the main components of the branch and bound in function of the number of variable for the branch and bound with the conic objective branching. The category "Others" include variable selection, node selection, creation of nodes and other implementation related details.
#
# ```{r,echo=FALSE}
# timerep <- filter(temp,pb=="KP",OB=="cone") %>%
#   group_by(OB,n) %>%
#     summarize(additional_domi = 100, SLUB = mean(100-pcttpsdomiLUB), LB = mean(100-pcttpsdomiLUB-pcttpsSLUB), domi = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB), others = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB-pcttpsdomi) )
#
# timerep %>% ggplot(aes(x=n)) + geom_area( aes(y = additional_domi , fill = "Additional dominance tests for LUBs")) + geom_area( aes(y = SLUB , fill = "Computation of SLUBs")) + geom_area( aes(y = LB , fill = "LB set")) + geom_area( aes(y = domi , fill = "Dominance test")) + geom_area(aes(y = others , fill = "Others")) + xlab("Number of variables") + ylab("% of computational time") + ggtitle("Cone objective branching")
# ```
#
# #### Assignment
#
# Proportion of unsolved instances for each objective branching strategy in function of the number of variables for tri-objective Assignment problems.
#
# ```{r,echo=FALSE}
# t <- filter(temp,pb=="AS") %>% group_by(OB,n) %>% count(solved==1)
# t <- mutate(t,norm = 100*nn/3)
# t %>%
#   ggplot(aes(x=n, y=norm, group=OB, color=OB)) + geom_line() + xlab("number of variables") + ylab("number of instances solved") + ggtitle("Percentage of tri-objective Assignment problem instances solved") + ylim(0,100)
# ```
#
# Relative CPU time of the main components of the branch and bound in function of the number of variable for the branch and bound without objective branching. The category "Others" include variable selection, node selection, creation of nodes and other implementation related details.
#
# ```{r,echo=FALSE}
# # time repartition stat
#
# timerep <- filter(temp,pb=="AS",OB=="None") %>%
#   group_by(OB,n) %>%
#     summarize(additional_domi = 100, SLUB = mean(100-pcttpsdomiLUB), LB = mean(100-pcttpsdomiLUB-pcttpsSLUB), domi = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB), others = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB-pcttpsdomi) )
#
# timerep %>% ggplot(aes(x=n)) + geom_area( aes(y = additional_domi , fill = "Additional dominance tests for LUBs")) + geom_area( aes(y = SLUB , fill = "Computation of SLUBs")) + geom_area( aes(y = LB , fill = "LB set")) + geom_area( aes(y = domi , fill = "Dominance test")) + geom_area(aes(y = others , fill = "Others")) + xlab("Number of variables") + ylab("% of computational time") + ggtitle("No objective branching")
# ```
#
# Relative CPU time of the main components of the branch and bound in function of the number of variable for the branch and bound with exact objective branching. The category "Others" include variable selection, node selection, creation of nodes and other implementation related details.
#
# ```{r,echo=FALSE}
# timerep <- filter(temp,pb=="AS",OB=="exact") %>%
#   group_by(OB,n) %>%
#     summarize(additional_domi = 100, SLUB = mean(100-pcttpsdomiLUB), LB = mean(100-pcttpsdomiLUB-pcttpsSLUB), domi = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB), others = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB-pcttpsdomi) )
#
# timerep %>% ggplot(aes(x=n)) + geom_area( aes(y = additional_domi , fill = "Additional dominance tests for LUBs")) + geom_area( aes(y = SLUB , fill = "Computation of SLUBs")) + geom_area( aes(y = LB , fill = "LB set")) + geom_area( aes(y = domi , fill = "Dominance test")) + geom_area(aes(y = others , fill = "Others")) + xlab("Number of variables") + ylab("% of computational time") + ggtitle("Exact objective branching")
# ```
#
# Relative CPU time of the main components of the branch and bound in function of the number of variable for the branch and bound with the conic objective branching. The category "Others" include variable selection, node selection, creation of nodes and other implementation related details.
#
# ```{r,echo=FALSE}
# timerep <- filter(temp,pb=="AS",OB=="cone") %>%
#   group_by(OB,n) %>%
#     summarize(additional_domi = 100, SLUB = mean(100-pcttpsdomiLUB), LB = mean(100-pcttpsdomiLUB-pcttpsSLUB), domi = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB), others = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB-pcttpsdomi) )
#
# timerep %>% ggplot(aes(x=n)) + geom_area( aes(y = additional_domi , fill = "Additional dominance tests for LUBs")) + geom_area( aes(y = SLUB , fill = "Computation of SLUBs")) + geom_area( aes(y = LB , fill = "LB set")) + geom_area( aes(y = domi , fill = "Dominance test")) + geom_area(aes(y = others , fill = "Others")) + xlab("Number of variables") + ylab("% of computational time") + ggtitle("Cone objective branching")
# ```
#
# #### Facility location easy
#
# Proportion of unsolved instances for each objective branching strategy in function of the number of variables for tri-objective Assignment problems.
#
# ```{r,echo=FALSE}
# t <- filter(temp,pb=="FLe") %>% group_by(OB,n) %>% count(solved==1)
# t <- mutate(t,norm = 100*nn/3)
# t %>%
#   ggplot(aes(x=n, y=norm, group=OB, color=OB)) + geom_line() + xlab("number of variables") + ylab("number of instances solved") + ggtitle("Percentage of tri-objective Assignment problem instances solved") + ylim(0,100)
# ```
#
# Relative CPU time of the main components of the branch and bound in function of the number of variable for the branch and bound without objective branching. The category "Others" include variable selection, node selection, creation of nodes and other implementation related details.
#
# ```{r,echo=FALSE}
# # time repartition stat
#
# timerep <- filter(temp,pb=="FLe",OB=="None") %>%
#   group_by(OB,n) %>%
#     summarize(additional_domi = 100, SLUB = mean(100-pcttpsdomiLUB), LB = mean(100-pcttpsdomiLUB-pcttpsSLUB), domi = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB), others = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB-pcttpsdomi) )
#
# timerep %>% ggplot(aes(x=n)) + geom_area( aes(y = additional_domi , fill = "Additional dominance tests for LUBs")) + geom_area( aes(y = SLUB , fill = "Computation of SLUBs")) + geom_area( aes(y = LB , fill = "LB set")) + geom_area( aes(y = domi , fill = "Dominance test")) + geom_area(aes(y = others , fill = "Others")) + xlab("Number of variables") + ylab("% of computational time") + ggtitle("No objective branching")
# ```
#
# Relative CPU time of the main components of the branch and bound in function of the number of variable for the branch and bound with exact objective branching. The category "Others" include variable selection, node selection, creation of nodes and other implementation related details.
#
# ```{r,echo=FALSE}
# timerep <- filter(temp,pb=="FLe",OB=="exact") %>%
#   group_by(OB,n) %>%
#     summarize(additional_domi = 100, SLUB = mean(100-pcttpsdomiLUB), LB = mean(100-pcttpsdomiLUB-pcttpsSLUB), domi = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB), others = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB-pcttpsdomi) )
#
# timerep %>% ggplot(aes(x=n)) + geom_area( aes(y = additional_domi , fill = "Additional dominance tests for LUBs")) + geom_area( aes(y = SLUB , fill = "Computation of SLUBs")) + geom_area( aes(y = LB , fill = "LB set")) + geom_area( aes(y = domi , fill = "Dominance test")) + geom_area(aes(y = others , fill = "Others")) + xlab("Number of variables") + ylab("% of computational time") + ggtitle("Exact objective branching")
# ```
#
# Relative CPU time of the main components of the branch and bound in function of the number of variable for the branch and bound with the conic objective branching. The category "Others" include variable selection, node selection, creation of nodes and other implementation related details.
#
# ```{r,echo=FALSE}
# timerep <- filter(temp,pb=="FLe",OB=="cone") %>%
#   group_by(OB,n) %>%
#     summarize(additional_domi = 100, SLUB = mean(100-pcttpsdomiLUB), LB = mean(100-pcttpsdomiLUB-pcttpsSLUB), domi = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB), others = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB-pcttpsdomi) )
#
# timerep %>% ggplot(aes(x=n)) + geom_area( aes(y = additional_domi , fill = "Additional dominance tests for LUBs")) + geom_area( aes(y = SLUB , fill = "Computation of SLUBs")) + geom_area( aes(y = LB , fill = "LB set")) + geom_area( aes(y = domi , fill = "Dominance test")) + geom_area(aes(y = others , fill = "Others")) + xlab("Number of variables") + ylab("% of computational time") + ggtitle("Cone objective branching")
# ```
#
# #### Facility location hard
#
# Proportion of unsolved instances for each objective branching strategy in function of the number of variables for tri-objective Assignment problems.
#
# ```{r,echo=FALSE}
# t <- filter(temp,pb=="FLh") %>% group_by(OB,n) %>% count(solved==1)
# t <- mutate(t,norm = 100*nn/3)
# t %>%
#   ggplot(aes(x=n, y=norm, group=OB, color=OB)) + geom_line() + xlab("number of variables") + ylab("number of instances solved") + ggtitle("Percentage of tri-objective Assignment problem instances solved") + ylim(0,100)
# ```
#
# Relative CPU time of the main components of the branch and bound in function of the number of variable for the branch and bound without objective branching. The category "Others" include variable selection, node selection, creation of nodes and other implementation related details.
#
# ```{r,echo=FALSE}
# # time repartition stat
#
# timerep <- filter(temp,pb=="FLh",OB=="None") %>%
#   group_by(OB,n) %>%
#     summarize(additional_domi = 100, SLUB = mean(100-pcttpsdomiLUB), LB = mean(100-pcttpsdomiLUB-pcttpsSLUB), domi = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB), others = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB-pcttpsdomi) )
#
# timerep %>% ggplot(aes(x=n)) + geom_area( aes(y = additional_domi , fill = "Additional dominance tests for LUBs")) + geom_area( aes(y = SLUB , fill = "Computation of SLUBs")) + geom_area( aes(y = LB , fill = "LB set")) + geom_area( aes(y = domi , fill = "Dominance test")) + geom_area(aes(y = others , fill = "Others")) + xlab("Number of variables") + ylab("% of computational time") + ggtitle("No objective branching")
# ```
#
# Relative CPU time of the main components of the branch and bound in function of the number of variable for the branch and bound with exact objective branching. The category "Others" include variable selection, node selection, creation of nodes and other implementation related details.
#
# ```{r,echo=FALSE}
# timerep <- filter(temp,pb=="FLh",OB=="exact") %>%
#   group_by(OB,n) %>%
#     summarize(additional_domi = 100, SLUB = mean(100-pcttpsdomiLUB), LB = mean(100-pcttpsdomiLUB-pcttpsSLUB), domi = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB), others = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB-pcttpsdomi) )
#
# timerep %>% ggplot(aes(x=n)) + geom_area( aes(y = additional_domi , fill = "Additional dominance tests for LUBs")) + geom_area( aes(y = SLUB , fill = "Computation of SLUBs")) + geom_area( aes(y = LB , fill = "LB set")) + geom_area( aes(y = domi , fill = "Dominance test")) + geom_area(aes(y = others , fill = "Others")) + xlab("Number of variables") + ylab("% of computational time") + ggtitle("Exact objective branching")
# ```
#
# Relative CPU time of the main components of the branch and bound in function of the number of variable for the branch and bound with the conic objective branching. The category "Others" include variable selection, node selection, creation of nodes and other implementation related details.
#
# ```{r,echo=FALSE}
# timerep <- filter(temp,pb=="FLh",OB=="cone") %>%
#   group_by(OB,n) %>%
#     summarize(additional_domi = 100, SLUB = mean(100-pcttpsdomiLUB), LB = mean(100-pcttpsdomiLUB-pcttpsSLUB), domi = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB), others = mean(100-pcttpsdomiLUB-pcttpsSLUB-pcttpsLB-pcttpsdomi) )
#
# timerep %>% ggplot(aes(x=n)) + geom_area( aes(y = additional_domi , fill = "Additional dominance tests for LUBs")) + geom_area( aes(y = SLUB , fill = "Computation of SLUBs")) + geom_area( aes(y = LB , fill = "LB set")) + geom_area( aes(y = domi , fill = "Dominance test")) + geom_area(aes(y = others , fill = "Others")) + xlab("Number of variables") + ylab("% of computational time") + ggtitle("Cone objective branching")
# ```
#
#
#
#
#
#
#
# ## General performance profile
#
# All instances are considered here at once. Who is the most efficient when we have no information available about the specificities of the coefficients of the instance ?
#
# ```{r, echo=FALSE}
#
# st <- seq(0,4,by=0.5)
# val1 <- rep(0,length(st))
# t <- filter(datOB, OB=="None")
# for (i in 1:length(st)) {
#   bidouille <- count(t,tpstotal <= st[i])
#   bidouille <- filter(bidouille,bidouille[1]!=FALSE)
#   if (count(bidouille) == 0) {
#     numer <- 0
#   }
#   else{
#     numer <- bidouille[[1,2]]
#   }
#   val1[i] <- 100*numer/count(t)[[1]]
# }
# val2 <- rep(0,length(st))
# t <- filter(datOB, OB=="exact")
# for (i in 1:length(st)) {
#   bidouille <- count(t,tpstotal <= st[i])
#   bidouille <- filter(bidouille,bidouille[1]!=FALSE)
#   if (count(bidouille) == 0) {
#     numer <- 0
#   }
#   else{
#     numer <- bidouille[[1,2]]
#   }
#   val2[i] <- 100*numer/count(t)[[1]]
# }
# val3 <- rep(0,length(st))
# t <- filter(datOB, OB=="cone")
# for (i in 1:length(st)) {
#   bidouille <- count(t,tpstotal <= st[i])
#   bidouille <- filter(bidouille,bidouille[1]!=FALSE)
#   if (count(bidouille) == 0) {
#     numer <- 0
#   }
#   else{
#     numer <- bidouille[[1,2]]
#   }
#   val3[i] <- 100*numer/count(t)[[1]]
# }
# pl <- tibble( step=st , perfBasic=val1, perfOB=val2, perfCone=val3)
# pl %>% ggplot( aes(x=step)) + geom_line(aes(y=perfBasic,colour="none")) + geom_line(aes(y=perfOB,colour="exact")) + geom_line(aes(y=perfCone,colour="cone")) + xlab("time (sec)") + ylab("% of solved instances") + ggtitle("Performance profile of objective branching")
# ```
