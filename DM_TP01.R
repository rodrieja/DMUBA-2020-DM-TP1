# Carga de las colecciones----
# Instalacion de los paquetes necesarios
install.packages("mongolite")
library(mongolite)
# Carga de las colecciones
# Tweets
C_tweets <- mongo(collection = "tweets_mongo_covid19_reducido", db = "DMUBA")
C_retweets <- mongo(collection = "tweets_mongo_covid19_retweeteados", db = "DMUBA")
C_quotes <- mongo(collection = "tweets_mongo_covid19_quoteados_completo", db = "DMUBA")
# Usuarios
C_users_t <- mongo(collection = "users_mongo_covid19_reducido", db = "DMUBA")
C_users_r <- mongo(collection = "users_mongo_covid19_retweeteados", db = "DMUBA")
C_users_q <- mongo(collection = "users_mongo_covid19_quoteados", db = "DMUBA")

# Colecciones unwindeadas
# Unwindeada por hashtags
C_tweets_U_h <- mongo(collection = "tweets_mongo_covid19_reducido_U_hashtags", db = "DMUBA")
C_retweets_U_h <- mongo(collection = "tweets_mongo_covid19_retweeteados_U_hashtags", db = "DMUBA")
C_quotes_U_h <- mongo(collection = "tweets_mongo_covid19_quoteados_completo_U_hashtags", db = "DMUBA")

# Unwindeada por mentions
C_tweets_U_m <- mongo(collection = "tweets_mongo_covid19_reducido_U_mentions", db = "DMUBA")
C_retweets_U_m <- mongo(collection = "tweets_mongo_covid19_retweeteados_U_mentions", db = "DMUBA")
C_quotes_U_m <- mongo(collection = "tweets_mongo_covid19_quoteados_completo_U_mentions", db = "DMUBA")

# Unwindeada por urls
C_tweets_U_u <- mongo(collection = "tweets_mongo_covid19_reducido_U_urls", db = "DMUBA")
C_retweets_U_u <- mongo(collection = "tweets_mongo_covid19_retweeteados_U_urls", db = "DMUBA")
C_quotes_U_u <- mongo(collection = "tweets_mongo_covid19_quoteados_completo_U_urls", db = "DMUBA")

# El tipo de dato levantado desde Mongo es "Environment"
# class(tweets)
# class(users)

# Transformacion a dataframes 
tweets <- C_tweets$find('{}')
retweets <- C_retweets$find('{}')
quotes <- C_quotes$find('{}')

tweets_U_h <- C_tweets_U_h$find('{}')
retweets_U_h <- C_retweets_U_h$find('{}')
quotes_U_h <- C_quotes_U_h$find('{}')

tweets_U_m <- C_tweets_U_m$find('{}')
retweets_U_m <- C_retweets_U_m$find('{}')
quotes_U_m <- C_quotes_U_m$find('{}')

tweets_U_u <- C_tweets_U_u$find('{}')
retweets_U_u <- C_retweets_U_u$find('{}')
quotes_U_u <- C_quotes_U_u$find('{}')

users_t <- C_users_t$find('{}')
users_r <- C_users_r$find('{}')
users_q <- C_users_q$find('{}')

#Consistencia e integración básica----
# Cuantos NA hay en los dataframes por columna
users_cont_NA <- round(apply(is.na(users),2,sum)/nrow(users)*100,1)
users_cont_NA

tweets_cont_NA <- round(apply(is.na(tweets),2,sum)/nrow(tweets)*100,1)
tweets_cont_NA

# Cantidad de duplicados entre colecciones
# Tweets
# quotes
1-sum(quotes$quoted_status_id %in% tweets$status_id)/length(unique(quotes$quoted_status_id))
# retweets
1-sum(retweets$retweet_status_id %in% tweets$status_id)/length(unique(retweets$retweet_status_id))

# Usuarios
#quotes
1-sum(users_q$quoted_user_id %in% users_t$user_id)/length(unique(users_q$quoted_user_id))
#retweets
1-sum(users_r$retweet_user_id %in% users_t$user_id)/length(unique(users_r$retweet_user_id))

# Los tweets a los que se responde, estan en la coleccion?
sum(tweets$reply_to_status_id %in% c(quotes$quoted_status_id,
                                 retweets$retweet_status_id,
                                 tweets$status_id))
length(unique(tweets[!is.na(tweets$reply_to_status_id),]$status_id))

# Distincion de instancias agregadas al integrar
# Usuarios
length(unique(users_t$user_id))
length(unique(c(users_t$user_id,users_r$retweet_user_id)))
length(unique(c(users_t$user_id,users_q$quoted_user_id)))
length(unique(c(users_t$user_id,users_r$retweet_user_id,users_q$quoted_user_id)))

# Tweets
length(unique(tweets$status_id))
length(unique(c(tweets$status_id,retweets$retweet_status_id)))
length(unique(c(tweets$status_id,quotes$quoted_status_id)))
length(unique(c(tweets$status_id,retweets$retweet_status_id,quotes$quoted_status_id)))

# Caputra de entidades----
install.packages("tm")
library(tm)
library(stringr)
library(stringi)

pattern_hashtag <- "#(\\w{1,})\\W"
pattern_mention <- "@(\\w{1,})\\W"
pattern_urls <- "https://(\\w{1,})\W"

hashtags <- function(x){
  x1 <- str_extract_all(x,pattern_hashtag,simplify=TRUE)
  x2 <- str_sub(x1,2,str_length(x1))
  x3 <- stri_trans_general(x2, "Latin-ASCII")
  x4 <- str_trim(x3)
  x5 <- str_to_lower(x4)
  x6 <- removePunctuation(x5, preserve_intra_word_contractions = FALSE, preserve_intra_word_dashes = FALSE) # eliminación de espacios en blanco
  return (x6)
}
mentions <- function(x){
  x1 <- str_extract_all(x,pattern_mention,simplify=TRUE)
  x2 <- str_sub(x1,2,str_length(x1))
  x3 <- stri_trans_general(x2, "Latin-ASCII")
  x4 <- str_trim(x3)
  x5 <- str_to_lower(x4)
  x6 <- removePunctuation(x5, preserve_intra_word_contractions = FALSE, preserve_intra_word_dashes = FALSE) # eliminación de espacios en blanco
  return (x6)
}
urls <- function(x){
  x1 <- str_extract_all(x,pattern_urls,simplify=TRUE)
  x2 <- str_sub(x1,8,str_length(x1))
  x3 <- stri_trans_general(x2, "Latin-ASCII")
  x4 <- str_trim(x3)
  x5 <- str_to_lower(x4)
  x6 <- removePunctuation(x5, preserve_intra_word_contractions = FALSE, preserve_intra_word_dashes = FALSE) # eliminación de espacios en blanco
  return (x6)
}

# MAPAS DE PALABRAS----
install.packages("slam")
install.packages("wordcloud")
library(wordcloud)
# Hashtags
  # Tweets----
lista_hash_t <- hashtags(tweets$text)
# Renombro hashtags similares
lista_hash_t[lista_hash_t %in% c("covid19","covid???19","reportecovid19")] <- "covid"
lista_hash_t[lista_hash_t == ""] <- NA

table_hash_t <- sort(table(lista_hash_t),decreasing = TRUE)
df_hash_t <- as.data.frame(table_hash_t)
# el mapa:
wordcloud(df_hash_t$lista_hash_t[1:50],
          df_hash_t$Freq[1:50],
          rot.per=0.5,
          random.color = FALSE,
          colors=rev(colorRampPalette(brewer.pal(9,"YlOrRd"))(32)[seq(8,32,6)]))
  # Retweets----
lista_hash_r <- hashtags(retweets$retweet_text)
# Renombro hashtags similares
lista_hash_r[lista_hash_r %in% c("covid19","covid???19","reportecovid19")] <- "covid"
lista_hash_r[lista_hash_r == ""] <- NA

table_hash_r <- sort(table(lista_hash_r),decreasing = TRUE)
df_hash_r <- as.data.frame(table_hash_r)
# el mapa:
wordcloud(df_hash_r$lista_hash_r[1:50],
          df_hash_r$Freq[1:50],
          rot.per=0.5,
          random.color = FALSE,
          colors=rev(colorRampPalette(brewer.pal(9,"YlOrRd"))(32)[seq(8,32,6)]))
  # Quotes----
lista_hash_q <- hashtags(quotes$quoted_text)
# Renombro hashtags similares
lista_hash_q[lista_hash_q %in% c("covid19","covid???19","reportecovid19")] <- "covid"
lista_hash_q[lista_hash_q == ""] <- NA

table_hash_q <- sort(table(lista_hash_q),decreasing = TRUE)
df_hash_q <- as.data.frame(table_hash_q)
# el mapa:
wordcloud(df_hash_q$lista_hash_q[1:50],
          df_hash_q$Freq[1:50],
          rot.per=0.5,
          random.color = FALSE,
          colors=rev(colorRampPalette(brewer.pal(9,"YlOrRd"))(32)[seq(8,32,6)]))

  # Todos----
lista_hash_total <- c(lista_hash_t,lista_hash_r, lista_hash_q)
table_hash_total <- sort(table(lista_hash_total),decreasing = TRUE)
df_hash_total <- as.data.frame(table_hash_total)
# el mapa:
wordcloud(df_hash_total$lista_hash_total[1:60],
          df_hash_total$Freq[1:60],
          rot.per=0.8,
          random.color = FALSE,
          colors=rev(colorRampPalette(brewer.pal(9,"YlOrRd"))(32)[seq(8,32,6)]))


#----

# #quedatencasa
# Filtro dataframes que contienen ese hashtag
tweets_qec <- tweets[,]
retweets_qec <- retweets_U_h["quedateencasa" == hashtags(retweets_U_h$text),]
quotes_qec <- quotes_U_h["quedateencasa" == hashtags(quotes_U_h$text),]

total_qec <- merge(x=tweets_qec,y=retweets_qec, by.x="status_id", by.y="retweet_status_id", all = TRUE)
total_qec <- merge(x=total_qec,y=quotes_qec, by.x="status_id", by.y="quoted_status_id", all = TRUE)

# Escala logaritmica para los datos numericos en users
users_log <- as.data.frame(apply(users[,4:7],2,log10)) #Tiene un inconveniente con los campos que son 0
colSums(users[,4:7]==0) #Cantidad de ceros en las columnas numericas