# Verifico que existan los package requeridos
if (!require(mongolite))
  install.packages("mongolite")
if (!require(tm))
  install.packages("tm")
if (!require(mice))
  install.packages("mice")


library(mongolite)
library(tm)
library(mice)
library(arules)
library(ggplot2)

# Importo las funciones auxiliares
source("helpers/getNAPercentage.R")
source("helpers/subsetDataFrameByColumns.R")



# Comienzo el analisis exploratorio
# tweets
# Cargo las collections de MongoDB y las instancias
tweetsCollection = mongo(collection = "tweets_mongo_covid19", db = "DMUBA")
tweets = tweetsCollection$find('{}')

# Cantidad de Columnas
length(tweets)

# Nombres de las columnoas
names(tweets)

# Structura del DF
str(tweets)

# Resumen del DF
summary(tweets)
tweets$location

tweets$hashtags[!is.na(tweets$hashtags)][715]

tweets$ha

# Analizo la variabilidad de casos faltantes
nasTweets = getNAPercentage(tweets)

missingData = nasTweets[nasTweets$percentage > 0,]
orderedByPercentage = order(missingData$percentage, decreasing = TRUE)
missingData[orderedByPercentage,]


tweetsWithmissingData = subsetDataFrameByColumns(tweets, missingData$attribute)
names(tweetsWithmissingData)[order(names(tweetsWithmissingData))]

subset = c("country", "description", "hashtags", "urls_url", "media_url", "mentions_user_id", "quote_count",
           "reply_count", "retweet_user_id", "place_name", "reply_to_user_id", "url")

subset = c("country", "description", "hashtags", "place_name")

missingSubSet = subsetDataFrameByColumns(tweets, subset)

md.pattern(missingSubSet, rotate.names = TRUE)

subset = c("place_url", "place_name", "lat", "lng")

missingSubSet = subsetDataFrameByColumns(tweets, subset)

md.pattern(missingSubSet, rotate.names = TRUE)




# Probamos con una distribución siguiendo una secuenco Fibonacci 
missingPercentageFixed = arules::discretize(nasTweets$percentage,
                                        method = "fixed",
                                        breaks = c(0, 0.1, 10, 20, 30, 40,50, 60, 70, 80, 90, 100),
                                        labels = c("0%", "0%-10%", "10%-20%", "20%-30%", "30%-40%", "40%-50%", "50%-60%", "60%-70%", "70%-80%", "80%-90%", "90%-100%")
)

missingPercentageFixed

df = data.frame(missings = missingPercentageFixed)
summary(missingPercentageFixed)


p = ggplot(df, aes(missings))
p = p + geom_histogram(bins = 10,
                       stat = "count",
                       colour = "black")
p = p + labs(x = "Datos faltantes", 
             y = "Cantidad de columnas", 
             title = "Porcentaje de datos faltantes por columna",
             caption = "(collection tweets_mongo_covid19)")
p



# hist(nasTweets$percentage)

# c("created_at",  "favorite_count",  "retweet_count",  "followers_count",  "friends_count",  "listed_count",  "statuses_count",
#   "favourites_count",  "account_created_at",  "quote_count",  "reply_count",  "retweet_favorite_count",  "retweet_retweet_count",
#   "retweet_followers_count",  "retweet_friends_count",  "retweet_statuses_count",  "quoted_favorite_count",  "quoted_retweet_count",
#   "quoted_followers_count",  "quoted_friends_count",  "quoted_statuses_count")

# subsetDataFrameByColumns(tweets, numericAttributes)


scale(tweets$favourites_count)

boxplot(scale(tweets$favourites_count))
boxplot(tweets$created_at)

hist(tweets$favourites_count)

dfCorpus = Corpus(VectorSource(enc2utf8(tweets)))

# users
# Cargo las collections de MongoDB y las instancias
usersCollection = mongo(collection = "users_mongo_covid19", db = "DMUBA")
users = usersCollection$find('{}')

# Cantidad de Columnas
length(users)

# Nombres de las columnoas
names(users)

# Structura del DF
str(users)

# Resumen del DF
summary(users$listed_count)

# Analizo la variabilidad de casos NA
nasUsers = getNAPercentage(users)
hist(nasUsers$percentage)


md.pattern(users, rotate.names = TRUE)



hist(table(users$listed_count))

boxplot(scale(users$listed_count))
