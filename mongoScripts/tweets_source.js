db.tweets_mongo_covid19.aggregate(
   [
      {
         "$project":{
            "source":1,
            "created_at":1,
            "location":1,
            "verified":1,
            "is_retweet":1,
            "is_quote":1,
            "text":1,
            "text_length":{
               "$strLenBytes":"$text"
            },
            "url":1,
            "media_type":1,
            "tweet_type":{
               "$cond":{
                  "if":{
                     "$eq":[
                        "$is_retweet",
                        true
                     ]
                  },
                  "then":"retweet",
                  "else":{
                     "$cond":{
                        "if":{
                           "$eq":[
                              "$is_quote",
                              true
                           ]
                        },
                        "then":"quote",
                        "else":"tweet"
                     }
                  }
               }
            }
         }
      },
      {
         "$out":"tweets_source"
      }
   ]
)