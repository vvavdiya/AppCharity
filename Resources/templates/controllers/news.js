var TwitterNewsRow = nrequire('templates/views/twitter_news_row')
, FbNewsRow = nrequire('templates/views/fb_news_row')
, FbGraph = nrequire('lib/fb_graph')
, Twitter = nrequire('lib/twitter')
, FbNewsDetail = nrequire('templates/windows/fb_news_detail')
, TwitterNewsDetail = nrequire('templates/windows/twitter_news_detail')
, PullToRefresh = nrequire('/ui/pull_to_refresh')
, PropertyCache = nrequire('/lib/property_cache')
, Push = nrequire('/lib/push');

module.exports = function(view) {  
  var state = {fb_rows: [], tweet_rows: []};
  
  var tryTofinish = function() {
    var all_rows = sortBy('.created', state.fb_rows.concat(state.tweet_rows)).reverse();
    view.table.setData(all_rows);
  }
  
  var finishTwitter = function(tweets) {
    state.tweet_rows = tweets.map(function(n){ return TwitterNewsRow.render(n).row; });
    PropertyCache.set('tweets', tweets);
    tryTofinish();
  }
  
  var finishFb = function(news) {
    state.fb_rows = news.map(function(n){ return FbNewsRow.render(n).row; });
    PropertyCache.set('fb_news', news);
    tryTofinish();
  }
  
  var getNews = function(cb) {
    FbGraph.getNewsFeed('msf.english', function(news){ finishFb(news); if(cb) cb(); });
    Twitter.timeline({screen_name: "MSF_USA"}, finishTwitter);
  }
  
  var getCachedNews = function() {
    return PropertyCache.get('fb_news', finishFb) && PropertyCache.get('tweets', finishTwitter);
  }
  
  var getNewsIfItsBeenLongEnough = function() {
    if(PropertyCache.get('fb_news', id) && view.table.data && view.table.data[0]) return;
    getCachedNews() || getNews();
  }
  
  var openDetail = function(e) {
    if((e.source && e.source.id) == "twitter_action") { return; }

    var row = e.row;
    var detail = (row.kind === "fb") ? FbNewsDetail.render(row.news) : TwitterNewsDetail.render(row.news);
    Application.news.open(detail.win);
  }
  
  view.win.addEventListener('focus', getNewsIfItsBeenLongEnough);
  if(!isIPad) view.table.addEventListener('click', openDetail);

  Push.addAndroidSettingsEvent(view.win);
  
  if(!isAndroid) {
    PullToRefresh(function(end){
      getNews(end);
    }, view.table);
  }
};
