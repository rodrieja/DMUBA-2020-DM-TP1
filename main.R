# Se puede utilizar mongolite

# install.packages("mongolite")
library(mongolite)


tweets = mongo(collection = "tweets_mongo_covid19", db = "DMUBA")
users = mongo(collection = "users_mongo_covid19", db = "DMUBA")


query <- tweets$find('{}')


typeof(query)

summary(query)



