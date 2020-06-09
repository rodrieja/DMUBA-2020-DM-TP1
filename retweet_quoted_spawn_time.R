# Verifico que existan los package requeridos
if (!require(mongolite))
  install.packages("mongolite")
if (!require(ggplot2))
  install.packages("ggplot2")
if (!require(scales))
  install.packages("scales")
if (!require(arules))
  install.packages("arules")
if (!require(lubridate))
  install.packages("lubridate")
if (!require(dplyr))
  install.packages("dplyr")


library(ggplot2)
library(scales)
library(mongolite)
library(arules)
library(lubridate)
library(dplyr)


# Importo las funciones auxiliares
source("helpers/dateHistogram.R")

# Importo la collection con la información temporal de los retweets y quotes
tweetsCollection = mongo(collection = "retweet_quoted_spawn_time", db = "DMUBA")
tweets = tweetsCollection$find('{}')

summary(tweets)

# Distribución de frecuencia entre followers y friends
hist(log10(tweets$quoted_followers_count), breaks = 20, main="Followers de Quotes", ylab="Frecuencia", xlab = "Followers log10")
hist(log10(tweets$quoted_friends_count), breaks = 20, main="Friends de Quotes", ylab="Frecuencia", xlab = "Friends log10")
hist(log10(tweets$retweet_followers_count), breaks = 20, main="Followers de Retweets", ylab="Frecuencia", xlab = "Followers log10")
hist(log10(tweets$retweet_friends_count), breaks = 20, main="Friends de Retweets", ylab="Frecuencia", xlab = "Friends log10")

# Distribución temporal de los Retweets y Quotes
# Histograma de los tweets
dateHistogram(tweets$created_at, 1, "Fecha Creación", "Cantidad de Tweets")

# Resumen de los tiempos
summary(tweets$created_at)
summary(tweets$retweet_created_at)
summary(tweets$quoted_created_at)

# Se nota que hay una dispersión amplia para los quotes y retweets
# los quotes tiene tweets del 2010
hoursUntilQuotedNotNA = tweets$hoursUntilQuoted[!is.na(tweets$hoursUntilQuoted)]
summary(hoursUntilQuotedNotNA)

# Probamos con una distribución siguiendo una secuenco Fibonacci 
horasDiscretizadas = arules::discretize(hoursUntilQuotedNotNA,
                                        method = "fixed",
                                        breaks = c(0, 1, 2, 8, 21, 55, 120, 233, 610, 2584, 121393),
                                        labels = c("hora", "2hs", "8hs", "dia", "2dias", "semana", "2semanas", "mes", "trimeste", "+3meses")
                                        )
summary(horasDiscretizadas)

df = data.frame(quoted = horasDiscretizadas)
p <- ggplot(df, aes(quoted))
p <- p + geom_histogram(bins = 11, stat="count", colour="white")
p = p + labs(
  x = "",
  y = "Tweets",
  title = "Generación de quotes",
  caption = "(collection retweet_quoted_spawn_time)"
)
p

hoursUntilRetweetNotNA = tweets$hoursUntilRetweet[!is.na(tweets$hoursUntilRetweet)]
summary(hoursUntilRetweetNotNA)

horasDiscretizadas = arules::discretize(hoursUntilRetweetNotNA,
                                        method = "fixed",
                                        breaks = c(0, 1, 2, 8, 21, 55, 120, 233, 610, 2584, 121393),
                                        labels = c("hora", "2hs", "8hs", "dia", "2dias", "semana", "2semanas", "mes", "trimeste", "+3meses")
)

df = data.frame(retweet = horasDiscretizadas)
summary(horasDiscretizadas)

p <- ggplot(df, aes(retweet))
p <- p + geom_histogram(bins = 11, stat="count", colour="white")
p = p + labs(
  x = "",
  y = "Tweets",
  title = "Generación de retweets",
  caption = "(collection retweet_quoted_spawn_time)"
)
p

# Probamos agrupando los tweets del día, para observar la gran diferencia que existe
horasDiscretizadas = arules::discretize(hoursUntilRetweetNotNA,
                                        method = "fixed",
                                        breaks = c(0, 21, 55, 120, 233, 610, 2584, 121393),
                                        labels = c("dia", "2dias", "semana", "2semanas", "mes", "trimeste", "+3meses")
)

df = data.frame(retweet = horasDiscretizadas)
summary(horasDiscretizadas)

p <- ggplot(df, aes(retweet))
p <- p + geom_histogram(bins = 11, stat="count", colour="white")
p



# 
# 
# dateHistogram(tweets$quoted_created_at[!is.na(tweets$quoted_created_at)],
#               1,
#               "Fecha Creación Quoted",
#               "Cantidad de Quoted")
# 
# 
# retweets = tweets$retweet_created_at[!is.na(tweets$retweet_created_at)]
# length(retweets)
# 
# 
# retweets.order = order(as.Date(retweets, format = "%Y-%m-%d"))
# retweets[retweets.order]
# 
# dateHistogram(retweets[retweets.order][200:length(retweets)],
#               7,
#               "Fecha Creación Retweet",
#               "Cantidad de Retweet")
# dateDF = data.frame(
#   created = as.Date(tweets$created_at),
#   retweeted = as.Date(tweets$retweet_created_at),
#   quoted = as.Date(tweets$quoted_created_at)
# )
# 
# boxplot(dateDF[c("created", "retweeted", "quoted")], log)
# 
# boxplot(dateDF[c("retweeted")])
# 
# 
# tweets$hoursUntilQuoted[!(is.na(tweets$hoursUntilQuoted))]
# 
# summary(tweets$hoursUntilQuoted[!(is.na(tweets$hoursUntilQuoted))])
# 
# 
# # crea variables nuevas discretizaciones
# tweets$hoursUntilQuoted.cluster = arules::discretize(
#   tweets$hoursUntilQuoted,
#   method = "cluster",
#   breaks = 5,
#   labels = c("muy_bajo", "bajo", "medio", "alto", "muy_alto")
# )
# tweets$hoursUntilQuoted.frequency = arules::discretize(
#   tweets$hoursUntilQuoted,
#   method = "frequency",
#   breaks = 5,
#   labels = c("muy_bajo", "bajo", "medio", "alto", "muy_alto")
# )
# tweets$hoursUntilQuoted.interval = arules::discretize(
#   tweets$hoursUntilQuoted,
#   method = "interval",
#   breaks = 5,
#   labels = c("muy_bajo", "bajo", "medio", "alto", "muy_alto")
# )
# 
# tweets$hoursUntilQuoted.cluster = arules::discretize(tweets$hoursUntilQuoted,
#                                                      method = "cluster",
#                                                      breaks = 10)
# tweets$hoursUntilQuoted.frequency = arules::discretize(tweets$hoursUntilQuoted,
#                                                        method = "frequency",
#                                                        breaks = 10)
# tweets$hoursUntilQuoted.interval = arules::discretize(tweets$hoursUntilQuoted,
#                                                       method = "interval",
#                                                       breaks = 10)
# 
# 
# tweets$retweet_followers_count.cluster = arules::discretize(tweets$retweet_followers_count,
#                                                             method = "cluster",
#                                                             breaks = 10)
# tweets$retweet_followers_count.frequency = arules::discretize(tweets$retweet_followers_count,
#                                                               method = "frequency",
#                                                               breaks = 10)
# tweets$hretweet_followers_count.interval = arules::discretize(tweets$retweet_followers_count,
#                                                               method = "interval",
#                                                               breaks = 10)
# 
# interval_cuts = arules::discretize(
#   tweets$retweet_followers_count,
#   method = "interval",
#   breaks = 5,
#   onlycuts = TRUE
# )
# frequency_cuts = arules::discretize(
#   tweets$retweet_followers_count,
#   method = "frequency",
#   breaks = 5,
#   onlycuts = TRUE
# )
# cluster_cuts = arules::discretize(
#   tweets$retweet_followers_count,
#   method = "cluster",
#   breaks = 5,
#   onlycuts = TRUE
# )
# log10_cuts =  10 ** unique(floor(log10(tweets$retweet_followers_count)))
# 
# 
# tweets[c("verified", "hoursUntilQuoted.frequency")]
# table(tweets[c("verified", "hoursUntilQuoted.frequency")])
# 
# # histograma
# hist(table(tweets$retweet_followers_count.frequency))
# 
# 
# 
# # método interval
# p <- ggplot(tweets, aes(x = retweet_followers_count)) +
#   geom_dotplot(dotsize = .6) +
#   ggtitle("Cortes en binning por igual ancho") +
#   xlab("cantidad de casos") +
#   theme_bw()
# for (cut in interval_cuts) {
#   # agrega cada corte al gráfico
#   p <- p + geom_vline(xintercept = cut,
#                       col = "red",
#                       linetype = "dashed")
# }
# p
