db.tweets_mongo_covid19.aggregate(
   [
      {
         "$match":{
            "$or":[
               {
                  "is_retweet":true
               },
               {
                  "is_quote":true
               }
            ]
         }
      },
      {
         "$project":{
            "created_at":1,
            "retweet_created_at":1,
            "retweet_count":1,
            "retweet_followers_count":1,
            "retweet_friends_count":1,
            "verified":1,
            "followers_count":1,
            "friends_count":1,
            "hoursUntilRetweet":{
               "$cond":{
                  "if":{
                     "$eq":[
                        "$retweet_created_at",
                        {

                        }
                     ]
                  },
                  "then":null,
                  "else":{
                     "$divide":[
                        {
                           "$subtract":[
                              "$created_at",
                              "$retweet_created_at"
                           ]
                        },
                        1000 * 60*60
                     ]
                  }
               }
            },
            "quoted_created_at":1,
            "quote_count":1,
            "hoursUntilQuoted":{
               "$cond":{
                  "if":{
                     "$eq":[
                        "$quoted_created_at",
                        {

                        }
                     ]
                  },
                  "then":null,
                  "else":{
                     "$divide":[
                        {
                           "$subtract":[
                              "$created_at",
                              "$quoted_created_at"
                           ]
                        },
                        1000 * 60*60
                     ]
                  }
               }
            }
         }
      }
   ]
)