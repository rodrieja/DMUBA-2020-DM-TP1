# Instalacion de los paquetes necesarios
install.packages("mongolite")
library(mongolite)

# Carga de las colecciones
tweets <- mongo(collection= "tweets_mongo_covid19_reducido", db="DMUBA")
users <- mongo(collection= "users_mongo_covid19_reducido", db="DMUBA")

# El tipo de dato levantado desde Mongo es "Environment"
class(tweets)
class(users)

# Transformacion a dataframes 
tweets <- tweets$find('{}')
users <- users$find('{}')

# Cuantos NA hay en los dataframes por columna
users_cont_NA <- round(apply(is.na(users),2,sum)/nrow(users)*100,1)
users_cont_NA

tweets_cont_NA <- round(apply(is.na(tweets),2,sum)/nrow(tweets)*100,1)
tweets_cont_NA

# Caputra de entidades
library(stringr)
pattern_hashtag <- "#(\\w{1,})\\W"
pattern_mention <- "@(\\w{1,})\\W"
pattern_urls <- "https://(\\w{1,})\W"

hashtags <- function(x){
  x1 <- str_extract_all(x,pattern_hashtag,simplify=TRUE)
  x2 <- str_sub(x1,2,str_length(x1))
  x3 <- str_trim(x2)
  return (x3)
}