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

# Partition step for multiple linear regression:
library(caret)
set.seed(2015)
sam <- createDataPartition(city.df$Geographic.area,
                           p=0.7, list = FALSE)
train <- city.df[sam, ]
validation<- city.df[-sam, ]

# multiple linear regression after partition
city7.lm <-lm(Median.Household.Income ~ X..below.poverty.level+X..over.25.completed.hs+share_white+share_black+share_native_american+ share_asian+share_hispanic, data = train)

summary(city7.lm)
