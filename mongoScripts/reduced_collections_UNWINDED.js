//---

// 2020-06-07

// Codigos usados para crear colecciones UNWINDEADAS con las que trabajar luego en R 
// UNWINDED por HASHTAGS
// TWEETS UNWINDED por hashtag
db.getCollection('tweets_mongo_covid19_reducido').aggregate([
        {$project: {'_id':0}},
        {$unwind:'$hashtags'},
        {$out:'tweets_mongo_covid19_reducido_U_hashtags'}
        ])

// RETWEETS UNWINDED por hashtag
db.getCollection('tweets_mongo_covid19_retweeteados').aggregate([
        {$project: {'_id':0}},
        {$unwind:'$hashtags'},
        {$out:'tweets_mongo_covid19_retweeteados_U_hashtags'}
        ])
        
// QUOTES UNWINDED por hashtags
db.getCollection('tweets_mongo_quoteados_completo').aggregate([
        {$project: {'_id':0}},
        {$unwind:'$hashtags'},
        {$out:'tweets_mongo_covid19_quoteados_completo_U_hashtags'}
        ])

// UNWINDED por MENTIONS
// TWEETS UNWINDED por mentions
db.getCollection('tweets_mongo_covid19_reducido').aggregate([
        {$project: {'_id':0}},
        {$unwind:'$mentions_user_id'},
        {$out:'tweets_mongo_covid19_reducido_U_mentions'}
        ])

// RETWEETS UNWINDED por hashtag
db.getCollection('tweets_mongo_covid19_retweeteados').aggregate([
        {$project: {'_id':0}},
        {$unwind:'$mentions_user_id'},
        {$out:'tweets_mongo_covid19_retweeteados_U_mentions'}
        ])
        
// QUOTES UNWINDED por hashtags
db.getCollection('tweets_mongo_quoteados_completo').aggregate([
        {$project: {'_id':0}},
        {$unwind:'$mentions_user_id'},
        {$out:'tweets_mongo_covid19_quoteados_completo_U_mentions'}
        ])

// UNWINDED por URLS
// TWEETS UNWINDED por mentions
db.getCollection('tweets_mongo_covid19_reducido').aggregate([
        {$project: {'_id':0}},
        {$unwind:'$urls_url'},
        {$out:'tweets_mongo_covid19_reducido_U_urls'}
        ])

// RETWEETS UNWINDED por hashtag
db.getCollection('tweets_mongo_covid19_retweeteados').aggregate([
        {$project: {'_id':0}},
        {$unwind:'$urls_url'},
        {$out:'tweets_mongo_covid19_retweeteados_U_urls'}
        ])
        
// QUOTES UNWINDED por hashtags
db.getCollection('tweets_mongo_quoteados_completo').aggregate([
        {$project: {'_id':0}},
        {$unwind:'$urls_url'},
        {$out:'tweets_mongo_covid19_quoteados_completo_U_urls'}
        ])
