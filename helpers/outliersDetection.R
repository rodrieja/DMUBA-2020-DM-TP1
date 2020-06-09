## DETECCION DE OUTLIERS
## ----------------------------------------------------

library(mongolite)
library(stringr)
library(stringi)
library(ggplot2)
library(Rlof)

tweets = mongo(collection = "tweets_mongo_covid19_reducido", db ="DMUBA")
tweets = tweets$find('{}')

users = mongo(collection = "users_mongo_covid19_reducido", db ="DMUBA")
users = users$find('{}')

# tweets_quoted = mongo(collection = "tweets_mongo_covid19_quoteados", db ="DMUBA")
# tweets_quoted = tweets_quoted$find('{}')

# tweets_retweet = mongo(collection = "tweets_mongo_covid19_retweeteados", db ="DMUBA")
# tweets_retweet = tweets_retweet$find('{}')


# users_quoted = mongo(collection = "users_mongo_covid19_quoteados", db ="DMUBA")
# users_quoted = users_quoted$find('{}')


# users_retweet = mongo(collection = "users_mongo_covid19_retweeteados", db ="DMUBA")
# users_retweet = users_retweet$find('{}')


 

# FILTRO VARIABLES NUMERICAS Y ANALISIS DE DATOS INICIALES
#-------------------------------------------------------------
names(tweets)
names(users)

num_cols <- unlist(lapply(tweets, is.numeric)) 
tweets = tweets[,num_cols]

num_cols <- unlist(lapply(users, is.numeric)) 
users = users[,num_cols]

summary(tweets)
summary(users)

# no utilizo tweets porque tiene todos datos = 0
resumen = apply(tweets,2,FUN= function(x) {sum(na.omit(x) != 0)})
resumen

#-----------------------------------------------
#  TRANSFORMACION DE DATOS
#-----------------------------------------------

users_n = data.frame(scale(log(users + 1)))

#-----------------------------------------------
#  BOXPLOTS CON OUTLIERS
#-----------------------------------------------

summary(users_n)

dev.off()
boxplot(users)
boxplot(users_n)


#-----------------------------------------------
#  PLOTS CON OUTLIERS
#-----------------------------------------------


plotDF = function(dataframe) {
  
  par(mfrow = c(3,2))
  cols = names(dataframe)
  for (i in 1:(length(cols))) {
    plot(sort(dataframe[[cols[i]]]), ylab=paste('scaled log',cols[i]))
  }
}

dev.off()
plotDF(users_n)

#-----------------------------------------------  
#  Z-SCORE
#-----------------------------------------------

# Genero DF de Z-scores

z_score = function (dataframe,desvios) {
  cols = names(dataframe)
  for (i in 1:(length(cols))) {
    x =  dataframe[[cols[i]]]
    m = mean(na.omit(x))
    sd = sd(na.omit(x))
    dataframe[!is.na(x),i] = (na.omit(x) - m)/sd
  }
  dataframe = dataframe < desvios
  dataframe
}

users_z = z_score(users,3)

# Genero matriz de datos filtrados

usersRmO_zs = list()
for (i in 1:ncol(users_n)) {
  usersRmO_zs[[i]] = (users_n[users_z[,i],i])
}
names(usersRmO_zs) = names(users)

#-----------------------------------------------
#  IQR
#-----------------------------------------------

iqrLimits = function (dataframe,margen) {
  iqr = apply(dataframe,2,FUN = function(x) {IQR(x)})
  q =  apply(dataframe,2,FUN = function(x) {quantile(x, c(0.25,0.75),type=7)})
  upperlimit = as.numeric(q[2]) + (iqr*margen)
  lowerlimit = as.numeric(q[1]) - (iqr*margen)
  limits = data.frame(rbind(lowerlimit,upperlimit))
  limits
}

users_iqr = iqrLimits(users_n,1.5)

# Genero matriz de datos filtrados

usersRmO_iqr = list()
for (i in 1:ncol(users_n)) {
  usersRmO_iqr[[i]] = (users_n[(users_n[[i]] > users_iqr[1,i]) & (users_n[[i]] < users_iqr[2,i]),i])
}
names(usersRmO_iqr) = names(users_n)


#-----------------------------------------------
#  BOXPLOTS SIN OUTLIERS
#-----------------------------------------------

# Metodo: z-score

dev.off()
boxplot(users_n)
boxplot(usersRmO_zs)
boxplot(usersRmO_iqr)




#-----------------------------------------------
#  PLOTS SIN OUTLIERS
#-----------------------------------------------


plotDF = function(dataframe) {
  
  par(mfrow = c(3,2))
  cols = names(dataframe)
  for (i in 1:(length(cols))) {
    plot(sort(dataframe[[cols[i]]]), ylab=paste('log',cols[i]))
  }
}

dev.off()
plotDF(users_n)
plotDF(usersRmO_zs)
plotDF(usersRmO_iqr)


#-----------------------------------------------
#  METODOS MULTIVARIADOS - LOF
#-----------------------------------------------

users1 = users_n[,c(1,2)]
users2 = users_n[,c(1,3)]
users3 = users_n[,c(1,4)]
users4 = users_n[,c(2,3)]
users5 = users_n[,c(2,4)]
users6 = users_n[,c(3,4)]

plot(users1)
plot(users2)
plot(users3)
plot(users4)
plot(users5)
plot(users6)

addLOF = function(dataframe,kvalue,umbral){
  dataframe$score = lof(dataframe, k = kvalue)
  dataframe$outlier = (dataframe$score > umbral)
  dataframe = na.omit(dataframe)
  dataframe$color = ifelse(dataframe$outlier, "red", "black")
  dataframe
}

users1 = addLOF(users1,3,3)
users2 = addLOF(users2,3,3)
users3 = addLOF(users3,3,3)
users4 = addLOF(users4,3,3)
users5 = addLOF(users5,3,3)
users6 = addLOF(users6,3,3)
plot(users1[[1]],users1[[2]], col=usersz$color)
plot(users2[[1]],users2[[2]], col=usersz$color)
plot(users3[[1]],users3[[2]], col=usersz$color)
plot(users4[[1]],users4[[2]], col=usersz$color)
plot(users5[[1]],users5[[2]], col=usersz$color)
plot(users6[[1]],users6[[2]], col=usersz$color)