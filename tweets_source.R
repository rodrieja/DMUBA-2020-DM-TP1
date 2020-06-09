

library(mongolite)
library(tm)
library(mice)
library(arules)
library(ggplot2)


tweetsCollection = mongo(collection = "tweets_source", db = "DMUBA")
source = tweetsCollection$find('{}')

sum(source$source=='Twitter for Android')

source$horas = as.integer(substr(source$created_at, 12, 13))
source$horasDiscretizadas = arules::discretize(
  source$horas,
  method = "fixed",
  breaks = c(0, 8, 11, 15, 20, 23),
  labels = c("Madrugada (0-8hs)", "Mañana (8-11hs)", "Mediodia (11-15hs)", "Tarde (15-20hs)", "Noche (20-24hs)")
)
summary(source$horas)
summary(source$horasDiscretizadas)



p = ggplot(source, aes(x = horasDiscretizadas, fill = tweet_type, color = tweet_type))
p = p + geom_histogram(position = "stack",
                       stat = "count",
                       alpha = 0.6)
p = p + labs(
  x = "Rango Horario",
  y = "Tweets",
  title = "Generación de contenido por horario",
  caption = "(collection tweets_source)"
)
p







p = ggplot(source,
           aes(x = horasDiscretizadas, fill = tweet_type, color = tweet_type))
p = p + geom_histogram(
  data = subset(source, tweet_type == 'retweet'),
  stat = "count",
  alpha = 0.4
)
p = p + geom_histogram(
  data = subset(source, tweet_type == 'tweet'),
  stat = "count",
  alpha = 0.6
)
p = p + geom_histogram(
  data = subset(source, tweet_type == 'quote'),
  stat = "count",
  alpha = 0.8
)
p = p + labs(
  x = "Rango Horario",
  y = "Tweets",
  title = "Generación de contenido por horario",
  caption = "(collection tweets_source)"
)
p




p = ggplot(source, aes(x = tweet_type, y = horas,  color = tweet_type))
p = p + geom_boxplot(outlier.colour="red")
p = p + labs(
  y = "Rango Horario",
  x = "Tweets",
  title = "Generación de contenido por horario",
  caption = "(collection tweets_source)"
)
p


horas = source[source$tweet_type == 'retweet',]$horas
length(horas)
summary(horas)

horas = source[source$tweet_type == 'quote',]$horas
length(horas)
summary(horas)

horas = source[source$tweet_type == 'tweet',]$horas
length(horas)
summary(horas)



summary(source$source)



length(unique(source$source))
# 175




sourceOrdered = tweetsCollection$aggregate('[
   {
      "$group":{
         "_id":"$source",
         "total":{
            "$sum":1
         }
      }
   },
   {
      "$sort":{
         "total":-1
      }
   }
]')

sourceTop10 = head(sourceOrdered, 10)
names(sourceTop10) = c("source", "count")

p = ggplot(sourceTop10, aes(x = reorder(source, -count), y=count))
p = p + geom_bar(stat="identity")
p = p + labs(
  x = "Rango Horario",
  y = "Tweets",
  title = "Generación de contenido por horario",
  caption = "(collection tweets_source)"
)
p


# 
# sourceTop5 = head(sourceOrdered, 5)
# names(sourceTop5) = c("source", "count")
# 
# p = ggplot(sourceTop5, aes(x = reorder(source, -count), y=count))
# p = p + geom_bar(stat="identity")
# p = p + labs(
#   x = "Rango Horario",
#   y = "Tweets",
#   title = "Generación de contenido por horario",
#   caption = "(collection tweets_source)"
# )
# p
# 
# 


# Filtro los registros que coinciden con el top 10
# filteredSource = source[source$source %in% sourceTop10$source, ]
# summary(filteredSource[c("is_retweet", "is_quote")])
# 
# 
# p = ggplot(filteredSource, aes(x = source, fill = tweet_type, color = tweet_type))
# p = p + geom_histogram(position = "identity",
#                        stat = "count",
#                        alpha = 0.6)
# p = p + labs(
#   x = "Rango Horario",
#   y = "Tweets",
#   title = "Generación de contenido por horario",
#   caption = "(Top 10 Source - collection tweets_source)"
# )
# p
# 
# sum(filteredSource$source=="Twitter for Android")



filteredSource5 = source[source$source %in% sourceTop5$source, ]
summary(filteredSource5[c("is_retweet", "is_quote")])


p = ggplot(filteredSource5, aes(x = source, fill = tweet_type, color = tweet_type))
p = p + geom_histogram(
  data = subset(filteredSource5, tweet_type == 'retweet'),
  stat = "count",
  alpha = 0.4
)
p = p + geom_histogram(
  data = subset(filteredSource5, tweet_type == 'tweet'),
  stat = "count",
  alpha = 0.6
)
p = p + geom_histogram(
  data = subset(filteredSource5, tweet_type == 'quote'),
  stat = "count",
  alpha = 0.8
)
p = p + labs(
  x = "Rango Horario",
  y = "Tweets",
  title = "Generación de contenido por plataforma",
  caption = "(Top 5 Sources - collection tweets_source)"
)
p



aggregate(is_retweet ~ source, filteredSource, sum)
aggregate(is_quote ~ source, filteredSource, sum)


p = ggplot(filteredSource, aes(x = source, y = horas,  color = tweet_type))
p = p + geom_boxplot(outlier.colour="red")
p = p + labs(
  y = "Rango Horario",
  x = "Plataforma",
  title = "Generación de contenido en plataformas por horario",
  caption = "(Top 10 Sources - collection tweets_source)"
)
p

