var redis = require('redis').createClient()

var item, multi = redis.multi();

var channel = "ady"

for (var i = 16; i < 20; i++) {

  item = {
    time: Date.now(),
    location: "0,0",
    data: "t_data_"+i
  }
  multi.hmset( "bump:"+channel+":"+i, item)
  multi.zadd( "bumps:"+channel, item.time, i );
  console.log(item)
};

// client.expire()


multi.exec(function(e,d){
  console.log('Done')
})
