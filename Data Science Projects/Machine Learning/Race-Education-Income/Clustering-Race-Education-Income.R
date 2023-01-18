#import data set
city.df <- read.csv("city.csv")

#ignore geographical area, city names, police killings columns
city.df <- city.df[,-1]
city.df <- city.df[,-1]
city.df <- city.df[,-9]

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

#run summary
summary(city.df)

#normalize data 
city.df.norm <- sapply(city.df,scale)
row.names(city.df.norm) <- row.names(city.df)

#run kmeans
set.seed(2)
km <- kmeans(city.df.norm, 3)

#plot clusters
plot(c(0), xaxt = 'n', ylab = "", type = "l", ylim = c(min(km$centers), max(km$centers)), xlim = c(0, 8))
axis(1, at = c(1:8), labels = names(city.df))
for (i in c(1:3))lines(km$centers[i,], lty = i, lwd = 3, col = ifelse(i %in% c(1, 3, 5),"black", "dark grey"))
text(x =0.5, y = km$centers[, 1], labels = paste("Cluster", c(1:3)))

dist(km$centers)
