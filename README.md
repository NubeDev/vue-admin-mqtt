Title: Real-time sensor data acquisition, transmission and display of 
the Author: Bruce the Sun (zlata.bruce @ qq.com ) 
a Date:-Nov, 25,, 2015 
the original plan based on a number of sensor data, for the cold chain industry, do a cold chain can be traced vehicle solutions, including hardware and software systems and cloud services. It finalized a prototype system that can display real-time temperature and humidity data, display GPS track transport vehicle on Baidu map. Of course, if you add a follow-up to the door switch sensor on the container, and then connected to a camera, a number of image data transmission to the PDA, there is no problem. 
This article just to record the prototype system uses technology, please look at our large cattle design, is not in line with real-time, high concurrency, further Tucao please, correct me.


# 0. environment to build
This prototype technology used is more, there is a list of what mosquitto, kafka, storm, redis etc., as well nodejs, socketIO, front-end development webpack, vuejs like. Environmental structures encountered the most difficult storm, of course, fairly smooth. Some problems are predecessors stepped pit, step by step, you can find a solution. In addition, I'll write some articles summarize the summary.

# 1. Architecture
Sensor data acquisition hardware platform dependent MQTT Publish, 3G data transmission to mosquitto, mqtt broker. And storm cloud kafka do with transport and cleaning data. Redis data store last month, another mongodb store all data, of course mysql relational database to store structured data, such as vehicle information distribution tasks. 
![image](./arch.png)
This design is reasonable, whether the devices send thousands Kang Zhu sensor data, the prototype has not been tested. But mqtt servre and cloud kafka, storm, etc. can load balancing to increase machine performance gains. Specific consideration or to go deep. Daniel has educated us. Software system built on top of the Ubuntu 16.04 Desktop, and later moved to Microsoft Azure Ubuntu Server 16.04

# 2.  Hardware Systems
MTK wireless routing solution platform, MT7620A, MTK single SOC solution for smart phone, AR9331,3G / GPS: Quectel UC20, temperature and humidity sensor is a Texas Instruments TI Sensor Tag. Sensor Tag rely BLE MTK platform and data interaction. MTK platform installed openwrt, is entirely a router.

# 3. Cloud Software Services
* MQTT(mosquitto)  
MQTT (mosquitto) 
The original plan was to use HTTP RESTFul. Cloud RESTFul complete the API, to provide hardware to call. After careful study and Restful mqtt, I feel mqtt more suitable. HTTP protocol is a short connection, consume more resources, for mobile devices, power is always a defect, contrary mqtt the TCP long connection can save a little energy. Of course, the deployment of a cloud mosquitto, greatly facilitate the transmission of messages. See more[see this](http://stephendnicholas.com/posts/power-profiling-mqtt-vs-https)。
  - MQTT Publish  
with Eclipse paho C language clients, collecting sensor data, and then send it. Own brain supplement.
  - MQTT Subsrible   
with paho Java client, does not intend to paste the code length of the segment. You can download the entire project behind.
``` java  
private static final String TOPIC = "topic_cctt_mqtt";
MqttClient subClient;
String broker       = "tcp://localhost:1883";
String clientId     = "cdata_sub";
MemoryPersistence persistence = new MemoryPersistence();
myKafkaDataPumbOut = new KafkaDataPumbOut();    	
subClient = new MqttClient(broker,clientId,persistence);
subClient.connect();
subClient.subscribe(TOPIC);
subClient.setCallback(this);
```  

Prototype also uses Javascript beginning of mqtt sub, get the data uploaded to the hardware, and then call Baidu map drawing functions, we made a car track applications. Specific code in the "frontend / client / views / components / BMapComponent.vue" inside, startMQTTClient method. 
In actual use, web application is the direct use mqtt sub acquire data or use socketio request from redis inside or ajax http to get inside the other db, what are the advantages and disadvantages, where there is no bottom.

* kafka
kafka mqtt sub after received data, send data directly to kafka in the queue, to kafka process.
```java
public void messageArrived(String topic, MqttMessage message) throws Exception {
    myKafkaDataPumbOut.publish("topic_cctt_kafka", message.toString());
    System.out.println("Publish to Kafka:" + message.toString());
}
```
* storm
storm storm directly KafkaSpout, to get the data from the corresponding topic kafka the queue. Here made two blot, do a standardized data segmented data from each sensor string, the second is to do store, directly in front of the wanted data, after JSON stored in Redis.

    ``` java
    String zkConnString= "localhost:2181";
    String topicName = "topic_cctt_kafka"; //this is kafka topic

    BrokerHosts hosts = new ZkHosts(zkConnString);
    SpoutConfig spoutConfig = new SpoutConfig(hosts,
    topicName, "" , "spout_bruce");
    spoutConfig.scheme = new SchemeAsMultiScheme(new StringScheme());
    spoutConfig.startOffsetTime = kafka.api.OffsetRequest.LatestTime();

    TopologyBuilder builder = new TopologyBuilder();
    DataKafkaSpout dataKafkaOut = new DataKafkaSpout(spoutConfig);
    builder.setSpout("data-kafka-spout", dataKafkaOut);

    builder.setBolt("data-normalizer-blot", new DataNormalizerBlot())
    .shuffleGrouping("data-kafka-spout");

    builder.setBolt("data-storage-blot", new DataStorageBlot())
    .shuffleGrouping("data-normalizer-blot");
    ```
* Redis
Redis is how to store data for a long time thinking, For relational databases, it is difficult to achieve the purpose, in the tangle for a long time, I feel that the redis Sorted sets, based on the score (score) of an ordered list of more suitable for storing such data. 
Such characteristics data are based on the timeline of the dataset, the query time is based on the time range to query. I will timestamp is converted to type long as the score of an ordered list, each data java object to Json after storage.
``` java
DateFormat format = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss",
 Locale.ENGLISH);
long score = format.parse(strTime).getTime();
jedis.zadd(redis_date_key, score,strDataObject);
```

* Web protal
vuejs & vue admin 
before jquery and bootstrap fairly familiar with the front end of the great changes in recent years, there are too many interesting things occur, vuejs is one of them. The prototyping, to see this js front frame, the advantages do not have to say any more. For me personally, not playing very slip. Which felt good and it fit css / UI framework is missing. Far from just spend a few dollars to buy a good UI to cool before. vue admin UI is a free theme vuejs, I used to read the code learning vuejs used. 
Learning vuejs a place of torment, some grammatical vue admin used, vuejs official documentation is hard to find, but also confused, it is estimated that the front end of my poor basis for comparison, look relatively small.
baidu echarts and map 
unquestioned Baidu both applications, very powerful, echarts very powerful. Someone has written echarts and map of veujs interface. Search npm above can be. But Baidu map yet, I searched for a high moral map of how to use the article in vuejs the Baidu map added to the list.
Gps running track to achieve the first track is in fact based on the track points on the map, draw polylines. Similar to the front of the taxi drops will change direction on the map, in fact, is the realization of the principle based on the calculated current point and the next point to be drawn in the direction of the vector, and then rotate the map over layer, which is marker.

  ```Javascript
  function setRotation (marker,curPos,targetPos){
      var me = this;
      var deg = 0;
      //start!
      curPos =  baiduMap.pointToPixel(curPos);
      targetPos =  baiduMap.pointToPixel(targetPos);
      if(targetPos.x != curPos.x){
              var tan = (targetPos.y - curPos.y)/(targetPos.x - curPos.x),
              atan  = Math.atan(tan);
              deg = atan*360/(2*Math.PI);
              //degree  correction;
              if(targetPos.x < curPos.x){
                  deg = -deg + 90 + 90;
              } else {
                  deg = -deg;
              }
              marker.setRotation(-deg);

      }else {
              var disy = targetPos.y- curPos.y ;
              var bias = 0;
              if(disy > 0)
                  bias=-1
              else
                  bias = 1
              marker.setRotation(-bias * 90);
      }
      return;
  }
  ```


# 4.Follow-up work
Hardware Integration

- Data security and authentication 
- prototype did not consider data security, there is no authentication. Follow-up to consider the authentication mqtt broker, kafka and storm the auth method.

# 5. repo
https://coding.net/u/zlata/p/kakapo/git
