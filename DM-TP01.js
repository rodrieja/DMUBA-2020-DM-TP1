//---
// 2020-05-25
// Codigos usados para crear colecciones reducidas con las que trabajar luego en R 
//---

// ------
// TWEETS
// ------
// Coleccion reducida de usarios (sin filtros)
db.getCollection('tweets_mongo_covid19').aggregate([
    {$match: {'is_retweet':true}},
    {$project: {'user_id':1,
                'status_id':1,
                'source':1,
                'text':1,
                'hashtags':1,
                'urls_url':1,
                'media_url':1,
                'media_type':1,
                'mentions_user_id':1,
                'created_at':1,
                'favorite_count':1,
                'retweet_count':1,
                'is_retweet':1,
                'is_quote':1,
                'reply_to_user_id':1,
                'reply_to_status_id':1}},
    {$out: 'tweets_mongo_covid19_reducido'}])

// -----
// USERS
// -----
// Coleccion reducida de usarios (sin filtros)
db.getCollection('users_mongo_covid19').aggregate([
    {$match: {}},
    {$project: {'user_id':1,'name':1,'location':1,'verified':1,'followers_count':1,'friends_count':1,'statuses_count':1,'favourites_count':1}},
    {$out: 'users_mongo_covid19_reducido'}])

// --------
// RETWEETS
// --------
// Coleccion reducida de tweets que fueron retweeteados (los originales)
db.getCollection('tweets_mongo_covid19').aggregate([
    {$match: {'is_retweet':true}},
    {$project: {'retweet_user_id':1,
                'retweet_status_id':1,
                'retweet_source':1,
                'retweet_text':1,
                'hashtags':1,
                'urls_url':1,
                'media_url':1,
                'media_type':1,
                'mentions_user_id':1,
                'retweet_created_at':1,
                'retweet_favorite_count':1,
                'retweet_retweet_count':1}},
    {$out: 'tweets_mongo_covid19_retweeteados'}])

// Coleccion reducida de usuarios cuyos tweeets fueron retweeteados
db.getCollection('tweets_mongo_covid19').aggregate([
    {$match: {'is_retweet':true}},
    {$project: {'retweet_user_id':1,
                'retweet_name':1,
                'retweet_followers_count':1,
                'retweet_friends_count':1,
                'retweet_statuses_count':1,
                'retweet_location':1,
                'retweet_verified':1}},
    {$out: 'users_mongo_covid19_retweeteados'}])

// ------
// QUOTES
// ------
// Coleccion reducida de tweets que fueron quoteados (los originales)
db.getCollection('tweets_mongo_covid19').aggregate([
    {$match: {'is_quote':true}},
    {$project: {'quoted_user_id':1,
                'quoted_status_id':1,
                'quoted_text':1,
                'hashtags':1,
                'quoted_created_at':1,
                'quoted_favorite_count':1,
                'quoted_retweet_count':1}},
    {$out: 'tweets_mongo_covid19_quoteados'}])

// Coleccion reducida de usuarios cuyos tweets fueron quoteados
db.getCollection('tweets_mongo_covid19').aggregate([
    {$match: {'is_quote':true}},
    {$project: {'quoted_user_id':1,
                'quoted_name':1,
                'quoted_followers_count':1,
                'quoted_friends_count':1,
                'quoted_statuses_count':1,
                'quoted_location':1,
                'quoted_verified':1}},
    {$out: 'users_mongo_covid19_quoteados'}])    
    