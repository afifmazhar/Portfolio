## import data
state_data <- 
  read_csv("data/state_data.csv")%>%
  dplyr::filter(1976<year & 1993 > year)

## twoway fixed effects
select_dep <- state_data[, c('lmur','lrap','laga','lrob','laut','lbur','llar')]

#Storing Independent Variables in List
select_dep <- state_data[ , c('lmur','lvio','laga','lpro','laut')]
# plm ols unweighted
plm_reg <- plm(lmur ~ shalll, data = state_data, index = c('state','year'),model = 'within', effect = "twoways")
plm_reg

# Table 1
fil_state <- state_data %>%
  subset(shalll == 1) %>%
  group_by(state)%>%
  summarize(year = min(year))
fil_state <- fil_state[order(fil_state$year), ]
fil_state <- stargazer(fil_state, summary = FALSE, float = FALSE)


# Table 2
select <- c('ratmur', 'ratvio', 'rataga', 'ratpro','aovio','aomur','aopro','aorap','aorob','aoaga','aobur','aolar','aoaut')
state_means <- aggregate(state_data[select], by = state_data['state'], function(x) c(mean = mean(x), sd = sd(x)))
summary_stats <- stargazer(state_means, summary = TRUE, float = FALSE)

# Table 3(Table 8a in Donohue) Regression UNWEIGHTED
for (i in 1:length(select_dep)) {
  nam = paste('full_',names(select_dep)[i],sep= "")
  frmla = as.formula(paste(names(select_dep[i]), '~ shalll + aovio + rpcpi + rpcim + rpcui  + rpcrpo + density + ppwm1019 + ppwm2029 + ppwm3039 + ppwm4049 + ppwm5064 + ppwm65o + ppbm1019 + ppbm2029 + ppbm3039 + ppbm4049 + ppbm5064 + ppbm65o + ppwf1019 + ppwf2029 + ppwf3039 + ppwf4049 + ppwf5064 + ppwf65o + ppbf1019 + ppbf2029 + ppbf3039 + ppbf4049 + ppbf5064 + ppbf65o + ppnm1019 + ppnm2029 + ppnm3039 + ppnm4049 + ppnm5064 + ppnm65o + ppnf1019 + ppnf2029 + ppnf3039 + ppnf4049 + ppnf5064 + ppnf65o +yr78 + yr79 + yr80 + yr81 + yr82 + yr83 + yr84 + yr85 + yr86 + yr87 + yr88 + yr89 + yr90 + yr91 + yr92+ popstate'))
  x = starprep(lm_robust(frmla,data = state_data, weight = popstate, fixed_effects = ~ stnumber, clusters = fipsstat, se_type = "stata"))
  assign(nam,x)
  
}
 
for (i in 1:length(select_dep)) {
  nam = paste('full_',names(select_dep)[i],sep= "")
  frmla = as.formula(paste(names(select_dep[i]), '~ shalll + aovio + rpcpi + rpcim + rpcui  + rpcrpo + density + ppwm1019 + ppwm2029 + ppwm3039 + ppwm4049 + ppwm5064 + ppwm65o + ppbm1019 + ppbm2029 + ppbm3039 + ppbm4049 + ppbm5064 + ppbm65o + ppwf1019 + ppwf2029 + ppwf3039 + ppwf4049 + ppwf5064 + ppwf65o + ppbf1019 + ppbf2029 + ppbf3039 + ppbf4049 + ppbf5064 + ppbf65o + ppnm1019 + ppnm2029 + ppnm3039 + ppnm4049 + ppnm5064 + ppnm65o + ppnf1019 + ppnf2029 + ppnf3039 + ppnf4049 + ppnf5064 + ppnf65o +yr78 + yr79 + yr80 + yr81 + yr82 + yr83 + yr84 + yr85 + yr86 + yr87 + yr88 + yr89 + yr90 + yr91 + yr92+ popstate'))
  x = starprep(lm_robust(frmla,data = state_data, weight = popstate, fixed_effects = ~ stnumber, clusters = fipsstat, se_type = "stata"))
  assign(nam,x)
  
}

# Table 8b Don: Dummy Regression w/ state trend

full_wls_wstate <- summary(lm_robust(lmur ~ shalll + aovio + rpcpi + rpcim + rpcui  + rpcrpo + density + ppwm1019 + ppwm2029 + ppwm3039 + ppwm4049 + ppwm5064 + ppwm65o + ppbm1019 + ppbm2029 + ppbm3039 + ppbm4049 + ppbm5064 + ppbm65o + ppwf1019 + ppwf2029 + ppwf3039 + ppwf4049 + ppwf5064 + ppwf65o + ppbf1019 + ppbf2029 + ppbf3039 + ppbf4049 + ppbf5064 + ppbf65o + ppnm1019 + ppnm2029 + ppnm3039 + ppnm4049 + ppnm5064 + ppnm65o + ppnf1019 + ppnf2029 + ppnf3039 + ppnf4049 + ppnf5064 + ppnf65o +yr78 + yr79 + yr80 + yr81 + yr82 + yr83 + yr84 + yr85 + yr86 + yr87 + yr88 + yr89 + yr90 + yr91 + yr92+ trndAK+trndAL+trndAZ+trndAR+trndCA+trndCO+trndCT + trndDC+trndDE+trndFL+trndGA+trndHI+trndIA+trndID+trndIL+trndIN+trndKS+trndKY+trndLA+trndMA+trndMD+trndME+trndMI+trndMN+trndMO+trndMS+trndMT+trndNC+trndND+trndNE+trndNH+trndNJ+trndNM+trndNV+trndNY+trndOH+trndOK+trndOR+trndPA+trndRI+trndSC+trndSD+trndTN+trndTX+trndUT+trndVA+trndVT+trndWA+trndWI+trndWV+trndWY+ popstate , data = state_data,clusters = fipsstat, weight = popstate, fixed_effects =  stnumber, se_type = "stata"))
full_wls_wstate

#Bacon Decomposition
x = NA
for(i in 1:length(select_dep))  {
  nam = paste('b',names(select_dep)[i],sep= "")
  frmla = as.formula(paste(names(select_dep[i]),'~ shalll'))
  x = bacon(frmla, state_data, id_var = 'state',time_var = 'year')
  x$weighted_est <- x$estimate * x$weight
  x = x %>%
    group_by(type) %>%
    summarize(weight = sum(weight),estimate = sum(weighted_est))
  x$estimate = x$estimate/x$weight
  assign(nam,x)  
}

#TWFE Estimate from bacon decomp
c_blmur <- sum(blmur$estimate * blmur$weight)
c_blvio <- sum(blaga$estimate * blmur$weight)
c_blaga <- sum(blaga$estimate * blmur$weight)

# Callaway Sant'anna
#Creating Group Table
fil_state_reg <- state_data %>%
  subset(shalll == 1) %>%
  group_by(state)%>%
  summarize(year = min(year))

#Adding Group to state_data
state_data <- merge(state_data,fil_state_reg,'state',all.x= TRUE)
state_data$year.y[is.na(state_data$year.y)]<- 0
state_data <- state_data %>%
  rename(Group = year.y) %>%
  rename(year = year.x)

#Callaway Sant'anna w/ 2 regressors, no anticipation
cs_reg <- att_gt(yname = 'lmur', tname = 'year',idname = 'fipsstat', gname = 'Group', xformla = ~rpcpi + lpolicerate, data= state_data )
cs_reg

# Event Study
state_data <- state_data %>%
  mutate(
    time_diff = year - Group,
    lead_1 = case_when(time_diff == -1 ~ 1, TRUE ~ 0),
    lead_2 = case_when(time_diff == -2 ~ 1, TRUE ~ 0),
    lead_3 = case_when(time_diff == -3~ 1, TRUE ~ 0),
    lead_4 = case_when(time_diff == -4 ~ 1, TRUE ~ 0),
    lead_5 = case_when(time_diff == -5 ~ 1, TRUE ~ 0),
    lead_6 = case_when(time_diff == -6 ~ 1, TRUE ~ 0),
    lead_7 = case_when(time_diff == -7 ~ 1, TRUE ~ 0),
    lead_8 = case_when(time_diff == -8 ~ 1, TRUE ~ 0),
    lead_9 = case_when(time_diff == -9 ~ 1, TRUE ~ 0),
    lead_10 = case_when(time_diff == -10 ~ 1, TRUE ~ 0),
    lead_11= case_when(time_diff == -11 ~ 1, TRUE ~ 0),
    lead_12 = case_when(time_diff == -12 ~ 1, TRUE ~ 0),
    lead_13 = case_when(time_diff == -13 ~ 1, TRUE ~ 0),
    lead_14 = case_when(time_diff == -14 ~ 1, TRUE ~ 0),
    lag_0 = case_when(time_diff == 0 ~ 1, TRUE ~ 0),
    lag_1 = case_when(time_diff == 1~ 1, TRUE ~ 0 ),
    lag_2 = case_when(time_diff == 2 ~ 1, TRUE ~ 0),
    lag_3 = case_when(time_diff == 3~ 1, TRUE ~ 0),
    lag_4 = case_when(time_diff == 4 ~ 1, TRUE ~ 0),
    lag_5 = case_when(time_diff == 5 ~ 1, TRUE ~ 0),
    lag_6 = case_when(time_diff == 6 ~ 1, TRUE ~ 0),
    lag_7 = case_when(time_diff == 7 ~ 1, TRUE ~ 0),
    lag_8 = case_when(time_diff == 8 ~ 1, TRUE ~ 0),
    lag_9 = case_when(time_diff == 9 ~ 1, TRUE ~ 0),
    lag_10 = case_when(time_diff == 10 ~ 1, TRUE ~ 0),
    lag_11= case_when(time_diff == 11 ~ 1, TRUE ~ 0),
    lag_12 = case_when(time_diff == 12 ~ 1, TRUE ~ 0),
    lag_13 = case_when(time_diff == 13 ~ 1, TRUE ~ 0),
    lag_14 = case_when(time_diff == 14 ~ 1, TRUE ~ 0)
  )
es_equation <- as.formula(
  paste('lmur~ + ',
        paste(
          paste(paste("lead_",1:14,sep = ""), collapse = " + "),
          paste(paste("lag_",1:14,sep = ""),collapse = " + "), sep = " + "),
        " | year + state | 0 | fipsstat"
  ),)
es_reg <- felm(es_equation,weights = state_data$popstate,  data = state_data)
es_reg
#Event Study Plot
x_axis <- c('lead_14','lead_13','lead_12','lead_11','lead_10','lead_9','lead_8','lead_7','lead_6','lead_5','lead_4',
            'lead_3','lead_2','lead_1','lag_1','lag_2','lag_3','lag_4','lag_5','lag_6','lag_7','lag_8','lag_9','lag_10',
            'lag_11','lag_12','lag_13','lag_14')
es_plot <- tibble(
  sd = c(es_reg$cse[x_axis],0),
  mean  = c(coef(es_reg)[x_axis],0),
  label = c(-14:14)
)
es_plot
es_plot %>%
  ggplot(aes(x = label, y = mean,
             ymin = mean-1.96*sd, 
             ymax = mean+1.96*sd)) +
  geom_pointrange() +
  theme_minimal() +
  xlab("Years from Right-to-Carry Law") +
  ylab("log(Homicide Rate)") +
  geom_hline(yintercept = 0,
             linetype = "dashed") +
  geom_vline(xintercept = 0,
             linetype = "dashed")


