#read data and packages
library(readr)
library(Synth)
library(tidyverse)
library(SCtools)
library(haven)
library(kableExtra)
library(stargazer)
library(xts)
library(zoo)
library(dplyr)
d <- read_csv("Code/Final_CI_datasetxlsx.csv")%>%
  as.data.frame(.)
#summary statistics table
select_indep <- c('Mining','Agriculture','Construction','Manufacturing','PCE','Personal Income','High School','Bachelor','Poverty Rate')
Table1 <- aggregate(d[select_indep], by = d['State'], function(x) c(mean = mean(x), sd = sd(x)))
summary_stats <- stargazer(Table1, summary = TRUE, float = FALSE, type = "latex", header = FALSE, omit.summary.stat = c("p25","p75","min","max"))

#synthetic control model
summary(d)
dataprep_out <- dataprep(
  foo = d,
  predictors = c("Poverty Rate", "PCE", "Personal Income", "High School", "Bachelor"),
  predictors.op = "mean", # the operation
  time.predictors.prior = 2005:2013,
  #beginning to the end
  special.predictors = list(
    list('GDP',2005:2013,'mean'),
    list('Mining', 2005:2013, 'mean'),
    list('Agriculture', 2005:2013,'mean'),
    list('Construction',2005:2013,'mean'),
    list('Manufacturing', 2005:2013,'mean')),
  dependent = 'GDP', #dv
  unit.variable = "State_Number", #identifying unit numbers
  unit.names.variable = 'State', #identifying unit names
  time.variable = 'Year', #time-periods
  treatment.identifier = 1, #the treated case
  controls.identifier = c(2:11), #the control cases; all others #except number 1
  time.optimize.ssr = 2005:2014,#the time-period over which to optimize
  time.plot = 2005:2020)#the entire time period before/after the treatment

typeof('State_Number')
synth_out <- invisible(synth(data.prep.obj = dataprep_out))

path.plot(synth_out, dataprep_out, 
          Ylab="Real Gross Domestic Product (state-level)",
          Xlab="Year",
          Legend = c("Colorado", "synthetic Colorado"),
          Legend.position = "bottomleft")%>%
  abline(v = 2014, col="darkgreen")
  
gaps = dataprep_out$Y1plot - (dataprep_out$Y0plot 
                              %*% synth_out$solution.w)
gaps[1:3,1]
gaps.plot(synth_out, dataprep_out, Ylab = "Gap in Real GDP growth")


placebos <- generate.placebos(dataprep_out, synth_out, Sigf.ipop = 3)

plot_placebos(placebos)

mspe.plot(placebos, discard.extreme = TRUE, mspe.limit = 1, plot.hist = TRUE)


synth.tables = synth.tab(dataprep.res = dataprep_out,
                         synth.res = synth_out)
names(synth.tables)
synth.tables$tab.w[1:10, ]
synth.tables$tab.pred[1:10,]

# plot the changes before and after the treatment 
path.plot(synth.res=synth_out,dataprep.res = dataprep_out, 
          Ylab="Real Gross Domestic Product of Colorado (1986 USD, thousand)",Xlab="year",
          Ylim = c(20000,30000),Legend = c("Colorado", 
                                    "synthetic Colorado"),
          Legend.position = "bottomright")

gaps.plot(synth.res = synth.out, dataprep.res = dataprep.out,
          Ylab = 'gap in real per-capita GDP (1986 USD, thousand)', Xlab= 'year',
          Ylim = c(-1.5,1.5), Main = NA)
