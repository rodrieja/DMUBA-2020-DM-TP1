# Verifico que existan los package requeridos
if (!require(mongolite))
  install.packages("mongolite")

library(mongolite)

# Importo las funciones auxiliares
source("helpers/getNAPercentage.R")



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

# Analizo la variabilidad de casos NA
nas = getNAPercentage(tweets)
hist(nas$percentage)




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
summary(users)

# Analizo la variabilidad de casos NA
nas = getNAPercentage(users)
hist(nas$percentage)



