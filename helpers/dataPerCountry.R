## CALCULO DE USUARIOS POR PAISES
## ----------------------------------------------------

library(tm)
library(mongolite)
library(stringr)
library(stringi)
library(wordcloud)
library(ggplot2)


tweets = mongo(collection = "tweets_mongo_covid19_reducido", db ="DMUBA")
tweets_quoted = mongo(collection = "tweets_mongo_covid19_quoteados", db ="DMUBA")
tweets_retweet = mongo(collection = "tweets_mongo_covid19_retweeteados", db ="DMUBA")

users = mongo(collection = "users_mongo_covid19_reducido", db ="DMUBA")
users_quoted = mongo(collection = "users_mongo_covid19_quoteados", db ="DMUBA")
users_retweet = mongo(collection = "users_mongo_covid19_retweeteados", db ="DMUBA")


tweets = tweets$find('{}')
tweets_quoted = tweets_quoted$find('{}')
tweets_retweet = tweets_retweet$find('{}')

users = users$find('{}')
users_quoted = users_quoted$find('{}')
users_retweet = users_retweet$find('{}')


# Funciones auxiliares

datosPorPais <- function(dataframe,campo_paises,num_paises,datos,grupo){

# Se quitan caracteres no alfanuméricos
dataframe[[campo_paises]] <- gsub("[^[:alnum:][:blank:]?&/\\-]", "", dataframe[[campo_paises]])
dataframe[[campo_paises]] <- gsub("U00..", "", dataframe[[campo_paises]])
# Se quitan acentos
dataframe[[campo_paises]]= stri_trans_general(dataframe[[campo_paises]], "Latin-ASCII")
# Se pasa a minusculas
dataframe[[campo_paises]] = tolower(dataframe[[campo_paises]])
# Se quita puntuacion
dataframe[[campo_paises]] = removePunctuation(dataframe[[campo_paises]])
# Se quitan números 
dataframe[[campo_paises]] = removeNumbers(dataframe[[campo_paises]])
# se quitan espacios extras
dataframe[[campo_paises]] = stripWhitespace(dataframe[[campo_paises]])
# se quitan espacios al principio y final de la cadena
dataframe[[campo_paises]] = str_trim(dataframe[[campo_paises]])
# sin stop words
dataframe[[campo_paises]] = removeWords(dataframe[[campo_paises]], stopwords("spanish"))
# Del listado aparecen estos paises más populares
countries_regex ="(argentina|mexico|colombia|costa rica|espana|peru|venezuela|chile|el salvador|ecuador|paraguay|guatemala|uruguay|honduras|nicaragua|bolivia|brasil)"
# Usamos expresiones regulares para extraer el país
dataframe$countries = str_extract(dataframe[[campo_paises]], countries_regex)

# ¿Qué contiene el campo location? Podemos contar frecuencias de palabras
countries_freq = data.frame(table(dataframe['countries']))
colnames(countries_freq) = c('countries','frec')
countries_grupo = aggregate(dataframe[[grupo]] ~ countries, FUN = sum, data = dataframe)
colnames(countries_grupo) = c('countries',grupo)
df_location_words = merge(countries_freq, countries_grupo, by='countries')
df_location_words <- head(df_location_words,num_paises)


p <- ggplot(df_location_words, aes(x = reorder(countries, frec), y = frec, fill=frec)) +
  geom_bar(stat = "identity") +
  theme_minimal() +
  scale_color_gradientn(colours = rainbow(10)) +
  ggtitle(paste(toupper(datos),'POR PAIS')) + # for the main title
  theme(plot.title = element_text(hjust = 0.5)) +
  theme(legend.position = 'none') +
  ylab(paste('Cantidad de', tolower(datos))) + # for the x axis label
  xlab('Paises') +# for the y axis label
  coord_flip()

p

}


#-----------------------------------------------------------------------------------
# MISSING VALUES: Users Location
#-----------------------------------------------------------------------------------
# Crea tabla de users location
col_t = c('user_id','country')
col_u = c('user_id','location','verified')

users_loc = users[col_u]
tweets_loc = tweets[col_t]
users_location = merge(users_loc,tweets_loc,by.x = 'user_id',by.y = 'user_id', all.x = TRUE)

# filas originales: 23435
nrow(users_loc)

# filas luego de merge: 28907
nrow(users_location)

# remove duplicates
users_location = users_location[!duplicated(users_location['user_id']),]

# filas sin duplicados: 23435
nrow(users_location)


# cantidad de ubicaciones: 15391
sum(is.na(users_location['location']))
# cantidad de ubicaciones: 60.51 %
100 * sum(!is.na(users_location['location']))/nrow(users_location)

# completa missing values
mask = (is.na(users_location['location']) & (!is.na(users_location['country'])))
users_location[mask,'location'] = users_location[mask,'country']

# cantidad de ubicaciones: 15432
sum(!is.na(users_location['location']))
# cantidad de ubicaciones: 60.67 %
100 * sum(!is.na(users_location['location']))/nrow(users_location)


#-----------------------------------------------------------------------------------
# MISSING VALUES: Tweets Location
#-----------------------------------------------------------------------------------
# Crea tabla de tweets location
col_t = c('user_id','country','is_retweet')
col_u = c('user_id','location')

users_loc = users[col_u]
tweets_loc = tweets[col_t]
tweets_location = merge(x=tweets_loc, y=users_loc,by.x = 'user_id',by.y = 'user_id',all.x = TRUE)

# filas originales: 28907
nrow(tweets_loc)

# filas luego de merge: 28907
nrow(tweets_location)

# cantidad de ubicaciones: 242
sum(!is.na(tweets_location['country']))
# cantidad de ubicaciones: 0.82 %
100 * sum(!is.na(tweets_location['country']))/nrow(tweets_location)

# completa missing values
mask = (is.na(tweets_location['country']) & (!is.na(tweets_location['location'])))
tweets_location[mask,'country'] = tweets_location[mask,'location']

# cantidad de ubicaciones: 17430
sum(!is.na(tweets_location['country']))
# cantidad de ubicaciones: 60.30 %
100 * sum(!is.na(tweets_location['country']))/nrow(tweets_location)


#-----------------------------------------------------------------------------------
# Grafica datos de users por location
datosPorPais(users_location,'location',15,'users','verified')
datosPorPais(tweets_location,'country',15,'tweets','is_retweet')







