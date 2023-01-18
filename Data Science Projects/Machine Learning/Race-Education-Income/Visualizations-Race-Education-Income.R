#import data set
city.df <- read.csv("city.csv")

#change to numeric values
city.df$share_white<- as.numeric(city.df$share_white)
city.df$share_black<- as.numeric(city.df$share_black)
city.df$share_native_american<- as.numeric(city.df$share_native_american)
city.df$share_asian<- as.numeric(city.df$share_asian)
city.df$share_hispanic<- as.numeric(city.df$share_hispanic)
city.df$Median.Household.Income<- as.numeric(city.df$Median.Household.Income)
city.df$X..over.25.completed.hs<- as.numeric(city.df$X..over.25.completed.hs)
city.df$X..below.poverty.level<- as.numeric(city.df$X..below.poverty.level)

#omit missing values 
na.omit(city.df) -> city.df

#box plots
boxplot(city.df$share_white, xlab = "share_white")
boxplot(city.df$share_black,xlab = "share_black")
boxplot(city.df$share_native_american, xlab = "share_native_american")
boxplot(city.df$share_asian, xlab = "share_asian")
boxplot(city.df$share_hispanic, xlab = "share_hispanic")

#histogram
hist(city.df$Median.Household.Income)

#scatterplot
plot(city.df$Median.Household.Income~ city.df$X..over.25.completed.hs, xlab = "percent over 25 completed hs", ylab = "Median Household Income")

