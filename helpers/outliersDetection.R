## DETECCION DE OUTLIERS
## ----------------------------------------------------

library(mongolite)
library(ggplot2)
library(Rlof)
library(cowplot)
# library(ggpubr)

tweets = mongo(collection = "tweets_mongo_covid19_reducido", db ="DMUBA")
tweets = tweets$find('{}')

users = mongo(collection = "users_mongo_covid19_reducido", db ="DMUBA")
users = users$find('{}')


# FILTRO VARIABLES NUMERICAS Y ANALISIS DE DATOS INICIALES
#-------------------------------------------------------------
names(tweets)
names(users)

num_cols <- unlist(lapply(tweets, is.numeric)) 
tweets = tweets[,num_cols]

num_cols <- unlist(lapply(users, is.numeric)) 
users = users[,num_cols]

View(summary(tweets))

# no utilizo tweets porque tiene todos datos = 0
resumen = apply(tweets,2,FUN= function(x) {sum(na.omit(x) != 0)})
resumen

#-----------------------------------------------
#  TRANSFORMACION DE DATOS
#-----------------------------------------------

users_ln = data.frame(scale(users))
users_n = data.frame(scale(log(users + 1)))

#-----------------------------------------------
#  ANALISIS ESTADISTICO
#-----------------------------------------------

summary(users_n)
data.frame(unclass(summary(users)), check.names = FALSE, stringsAsFactors = FALSE)
do.call(cbind, lapply(users, summary))


#-----------------------------------------------
#  BOXPLOTS CON OUTLIERS
#-----------------------------------------------

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

# Genero DF de Z-scores
users_z = z_score(users,3)

# genero filtro para remover todas las filas que tengas un z-score por fuera del limite 
filter = apply(users_z,1,FUN = function(x) {FALSE %in% x} )

# cantidad de filas a remover
sum(filter)

# df users sin outliers por z-score
summary(users[filter,])


# Analizo individualmente cada variable sin outliers

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

# Matriz de limites IQR
users_iqr = iqrLimits(users_n,1.5)


# Analizo individualmente cada variable sin outliers
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
par(mfrow = c(3,1))
boxplot(users_n, col = "cyan2", border="darkslategrey")
boxplot(usersRmO_zs, col = "cyan2", border="darkslategrey")
boxplot(usersRmO_iqr, col = "cyan2", border="darkslategrey")


#-----------------------------------------------
#  PLOTS SIN OUTLIERS
#-----------------------------------------------


plotDF = function(dataframe) {
  
  par(mfrow = c(3,2))
  cols = names(dataframe)
  for (i in 1:(length(cols))) {
    plot(sort(dataframe[[cols[i]]]), ylab=paste('log',cols[i]), col = "cyan4")
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
users4 = users_n[,c(1,5)]
users5 = users_n[,c(2,3)]
users6 = users_n[,c(2,4)]
users7 = users_n[,c(2,5)]
users8 = users_n[,c(3,4)]
users9 = users_n[,c(3,5)]
users10 = users_n[,c(4,5)]

addLOF = function(dataframe,kvalue,umbral){
  dataframe$score = lof(dataframe, k = kvalue)
  dataframe$outlier = (dataframe$score > umbral)
  dataframe = na.omit(dataframe)
  dataframe$color = ifelse(dataframe$outlier, "red", "black")
  dataframe
}

addMahalanobis = function(df, umbral){
  temp= df
  temp$mahalanobis <- mahalanobis(temp, colMeans(temp), cov(temp))
  
  # Ordenamos de forma decreciente, según el score de Mahalanobis
  # temp = temp[order(temp$mahalanobis,decreasing = TRUE),]
  
  # Descartamos los outliers según un umbral
  temp$outlier = (temp$mahalanobis>umbral)
  temp
}

print_plot(users_mh)print_plot = function (df) {
  p= ggplot(df, aes_string(x=names(df)[1], y=names(df)[2], color=names(df)[4])) +
    geom_point()  
  p
}


mh1 = addMahalanobis(users1,30)
p1=print_plot(mh1)
mh2 = addMahalanobis(users2,30)
p2=print_plot(mh2)
mh3 = addMahalanobis(users3,30)
p3=print_plot(mh3)
mh4 = addMahalanobis(users4,30)
p4=print_plot(mh4)
mh5 = addMahalanobis(users5,30)
p5=print_plot(mh5)
mh6 = addMahalanobis(users6,30)
p6=print_plot(mh6)
mh7 = addMahalanobis(users7,30)
p7=print_plot(mh7)
mh8 = addMahalanobis(users8,30)
p8=print_plot(mh8)
mh9 = addMahalanobis(users9,30)
p9=print_plot(mh9)
mh10 = addMahalanobis(users10,30)
p10=print_plot(mh10)


plot_grid(p1, p2, p3, p4, p5, p6, p7, p8, p9, p10, 
          labels = c("A", "B", "C"),
          ncol = 2, nrow = 5)

# genero filtro de matriz users
filter_mh = cbind( mh1$outlier,
                mh2$outlier,
                mh3$outlier,
                mh4$outlier,
                mh5$outlier,
                mh6$outlier,
                mh7$outlier,
                mh8$outlier,
                mh9$outlier,
                mh10$outlier)

# genero filtro para remover todas las filas que tengas un z-score por fuera del limite 
filter_mh = apply(filter_mh,1,FUN = function(x) {TRUE %in% x} )

# cantidad de filas a remover
sum(filter_mh)
