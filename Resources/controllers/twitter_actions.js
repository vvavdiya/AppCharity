Controllers.TwitterActions = function(view, tweet){
  
  var retweet = function() {
    Twitter.retweet(tweet.id_str, function(e) {
      if(e.success) UI.createAlertMessage("You've successfully retweeted!");
    });
  }
  
  var favorite = function() {
    Twitter.favorite(tweet.id_str, function(e) {
      if(e.success) UI.createAlertMessage("You've successfully favorited!");
    });
  }
  
  var reply = function() {
    view.tweet_view = Windows.Tweet(tweet.user.screen_name, function(text){
      Twitter.reply(tweet.id_str, text, function(e) {
        if(e.success) UI.createAlertMessage("You've successfully replied!");
      });
    });
    
    Windows.Application.news.open(view.tweet_view.win);
  }
  
  view.retweet.addEventListener('click', retweet);
  view.favorite.addEventListener('click', favorite);
  view.reply.addEventListener('click', reply);
}
