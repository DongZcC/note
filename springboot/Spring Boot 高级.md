# 一、 Spring Boot 与缓存

## 一、JSR107

Java Caching定义了5个核心接口，分别是CachingProvider， CacheManager， Cache， Entry和Expire

* CacheingProvider 定义了创建配置获取和管理多个CacheManager。一个应用可以在运行期访问多个CacheProvider
* CacheManager定义了创建配置获取和管理控制多个Cache。
* Cache 是一个类似Map的数据结构。
* Entry 是一个储存在Cache的试题
* Expire 过期时间

## 二、Spring缓存抽象

Spring从3.1开始，定义了Cache 和 CacheManager接口来统一不用的缓存技术。并支持使用 JSR-107注解 简化开发。

| 概念           | 解释                                                         |
| -------------- | ------------------------------------------------------------ |
| Cache          | 缓存接口，定义缓存操作，实现有RedisCache...                  |
| CacheManager   | 缓存管理器，管理各种Cache组件                                |
| @Cacheable     | 主要针对方法配置，能够根据方法的请求参数，对于结果进行缓存（有数据就不调用了） |
| @CacheEvict    | 缓存驱逐 ， 清理缓存  del                                    |
| @CachePut      | 保证方法被调用，又希望结果被缓存 update                      |
| @EnableCaching | 开启基于注解的缓存                                           |
| keyGenerator   | 缓存数据时key生成策略                                        |
| serialize      | 缓存数据时value的序列化                                      |

CacheManager 管理多个Cache组件，对缓存真正的CRUD操作在Cache组件中，每一个缓存组件有自己唯一的名字；

注解：

@Cacheable ：

```java
*  cacheNames/ value 缓存的名字
*  key： 缓存数据使用的key ；默认是使用方法参数的值。
*  keyGenerator: key的生成器；可以自己制定key的生成器的组件id
*  key / keyGenerator 二选一使用
*  cacheManager: 缓存管理器
*  cacheResolver: 解析缓存管理器
*  condition: 指定符合条件的情况下才缓存;
*  unless : 否定缓存, 当unless指定的条件为true ， 方法的返回值就不会被缓存
*  sync: 缓存是否使用异步模式
```



原理：

1、 自动配置类  ： CacheAutoConfiguration

```java
	/**
	 * {@link ImportSelector} to add {@link CacheType} configuration classes.
	 */
	static class CacheConfigurationImportSelector implements ImportSelector {

		@Override
		public String[] selectImports(AnnotationMetadata importingClassMetadata) {
			CacheType[] types = CacheType.values();
			String[] imports = new String[types.length];
			for (int i = 0; i < types.length; i++) {
				imports[i] = CacheConfigurations.getConfigurationClass(types[i]);
			}
			return imports;
		}

	}
```

2、 哪个自动配置类生效？  默认的是SimpleCacheConfiguration

​	给容器中注册了一个CacheManager ，ConcurrentMapCacheManager ； 来缓存ConcurrentMapCache这个对象。 从private final ConcurrentMap<Object, Object> store; 存取数据。



运行流程：

@Cacheable注解：

1、方法运行之前，先去查询Cache（缓存组件） ，安超cacheNames 指定的名字获取。 （CacheManager获取相应的缓存） 第一次获取缓存，如果没有缓存组件，会自动创建。

2、从Cache中查找缓存内容，使用key，默认为方法的参数。 

​	key是按照某种策略生成的。 SimpleKeyGenerator生成key默认策略；

​		如果没有参数： key = new SimpleKey（）；

​		如果有一个参数： key = 参数的值；

​		如果有多个参数： key = new SimpleKey(params);

3、没有查到缓存，就调用目标方法；

4、将目标方法返回的结果，放进缓存中。

5、 再次运行，直接返回缓存的对象。



### 整合redis

	1. 引入redis starter

```xml

		<dependency>
			<groupId>org.springframework.boot</groupId>
			<artifactId>spring-boot-starter-data-redis</artifactId>
		</dependency>
```

2. 配置redis ， spring.redis.  配置host
3. 测试缓存
   1. 原理 CacheManager === Cache 缓存组件，来实际上给组件进行缓存.
   2. 引入Redis的Starter 后， 容器中缓存的是RedisCacheManager ， 创建的是RedisCache 来作为缓存组件。RedisCache是通过操纵redis来操作数据。
   3. 默认保存数据 k-v 都是Object ； 利用序列化保存数据； 如何保存为json？ -- 更改RedisTemplate的serializer就OK了 自定义缓存管理器



# 二、 Spring Boot 与消息

1、 在大多应用中，可通过消息服务中间件来提升系统的异步通信、扩展解耦能力

2、消息服务理念中两个重要概念：

​	消息代理（message broker） 和 目的地（destination）

当消息发送者发送消息后，将由消息代理接管，消息代理保证消息传递到指定的目的地。

3、消息队列主要有两种形式的目的地

​	1、队列（queue）：点对点消息通信（point-to-point）

​	2、主题（topic）： 发布（push） / 订阅（subscribe） 消息通信

4、点对点式：

- 消息发送者发送消息，消息代理将其放入到一个队列中，消息接收着从队列中取出消息内容，消息读取后被移除队列
- 消息只有唯一的发送者，和接受者， 但是可以有多个接收着。  --  多消费者

5、发布订阅式

6、 JMS （Java Message Service） Java消息服务：

- 基于JVM消息代理的规范 ActiveMQ、 HornetMQ是JMS的实现。

7、 AMQP （Advanced Message Queuing Protocol）

- 高级消息队列协议，也是一个消息代理的规范，兼容JMS
- RabbitMQ是AMQP的实现



|              | JMS          | AMQP             |
| ------------ | ------------ | ---------------- |
| 定义         | Java API     | 网络协议         |
| 跨语言       | 否           | 是               |
| Model        | 两种消息类型 | 五种消息模型；   |
| 支持消息类型 | 多种消息类型 | 数据序列化后发送 |

8、Spring支持

- spring-jms对JMS提供支持
- spring-rabbit提供AMQP支持
- 需要ConnectionFactory的实现来连接消息代理
- 提供JmsTemplate 、RabbitTemplate来发送消息
- @JmsLisenter（JMS） 、 @RabbitListener（AMQP）——注解来监听消息代理发布的消息
- @EnableJms、@EnableRabbit开启支持



9、 Spring boot支持



应用场景：

1、流量削峰 （定长队列）

2、应用解耦（订阅发布）

3、异步处理（queue）



## RabbitMQ简介

是由erlang开发的AMQP的开源实现

核心概念：

* Message：

消息，消息是不具名的， 由消息头和消息体组成。消息体是不透明的，消息头则是一系列可选属性组成。 （route-key、priority）

* Publisher：

消息生产者，也是一个向Exchange发布消息的客户端应用程序

* Exchange：

交换器，用来接收生产者发送的消息，并将这些消息路由给服务器中的队列。

Exchange有四种类型： direct（默认） ， fanout， tipic， headers ，不同类型的Exchange转发消息策略有所区别。

* Queue： 消息队列，用来保存消息知道发送给消费者。他是消息的容器，也是消息的终点。一个消息可投入一个或多个队列。消息一直在队列里面。等待消费者连接到这个队列将其取走。
* Binding： 绑定，用于消息队列和交换器之间的关联。一个绑定就是基于路由键将叫魂器和消息队列连接起来的路由规则，所以可以将交换器理解成一个由绑定构成的路由表。Exchange 和Queue的绑定可以是多对多的关系。
* Connection ： 网络连接， 比如一个TCP连接
* Channel： 信道，多路复用连接中的一条独立的双向数据通道。信道是建立在真是的TCP连接内的虚拟连接，AMQP命令都是通过信道发出去的。不管是发送消息、订阅队列还是接收消息，这些动作都是通过信道完成。
* Consumer ： 消息消费者，表示一个从队列中获取的信息的客户端应用程序
* Virtual Host ： 虚拟主机， 表示一批交换器、消息队列和相关对象。虚拟主机是共享相同身份认证和加密环境的独立服务器域。每个vhost本质上就是一个mini版的RabbitMQ服务器，拥有自己的队列、交换器、绑定和权限机制。vhost是AMQO的概念基础**，必须在连接指定RabbitMQ默认的vhost是   /** 。
* Broker ： 表示消息队列服务器实体。



## RabbitMQ运行机制

AMQP中的消息路由

* AMQP中的消息路由过程和JMS存在一些差别， AMQP中增加了Exchange和Binding角色。

direct（默认） ： 必须路由键和队列名相同才可以

fanout：发送到fanout交换器的消息，会发送到所有绑定的队列上去。 很像子网广播

tipic：通过模式匹配分配消息的路邮件属性，将路由键属性，将路由键和某个模式匹配，此时队列需要绑定到一个模式上。他将路由键和绑定键的字符串分割  由  . 分隔 。符号“#” 和“* ” ， # 匹配 0 个 或多个 ，  * 匹配一个单词。

## RabbitMQ 整合

在新建工程的时候，选择amqp

导入后，如果需要改变端口等。就在配置文件中更改。

否则直接可以直接用RabbitTemplate ;

自动配置：

```java
/**
 * 自动配置：
 * 1.RabbitAutoConfiguration
 * 2.自动配置了CachingConnectionFactory
 * 3.RabbitProperties 封装了 RabbitMq的配置
 * 4.RabbitTemplate:给RabbitMQ发送消息
 * 5.AmqpAdmin: RabbitMQ系统管理功能组件
 * 6.  @EnableRabbit +  @RabbitListener 监听消息队列中的内容
 */
@EnableRabbit  // 开启基于注解的rabbitMQ
@SpringBootApplication
public class SpringBoot06AmqpApplication {

	public static void main(String[] args) {
		SpringApplication.run(SpringBoot06AmqpApplication.class, args);
	}
}
```



```java

@RunWith(SpringRunner.class)
@SpringBootTest
public class SpringBoot06AmqpApplicationTests {


    @Autowired
    private RabbitTemplate rabbitTemplate;


    /**
     * 测试几个消息
     * 1.单播(点对点)
     */
    @Test
    public void sendMsg() {
        // 需要自己定义消息体，和消息头序列化
        // rabbitTemplate.send();

        // 只需要传入要发送的对象，自动序列化， 保存发送给rabbitMq
        // rabbitTemplate.convertAndSend();
        Map<String, Object> obj = new HashMap<>();
        obj.put("msg", "这是第一个消息");
        obj.put("info", "123");
        rabbitTemplate.convertAndSend("exchange.direct", "atdzc.news", obj);
    }

    /**
     * 接收数据
     */
    @Test
    public void receive() {
        // 得到Message对象
        // rabbitTemplate.receive();

        Object o = rabbitTemplate.receiveAndConvert("atdzc.news");
        System.out.println(o.getClass());
        System.out.println(o);
    }
}

```

监听队列中的消息

```java
@Service
@Slf4j
public class BookService {

    @RabbitListener(queues = {"atdzc.news"})
    public void receive(Book book) {
        log.info("收到消息 : " + book);
    }

    @RabbitListener(queues = {"atdzc"})
    public void receiveMsg(Message message) {
        System.out.println(message.getBody());
        System.out.println(message.getMessageProperties());
    }
}
```

## AMQPadmin管理功能

创建和删除， Queue ， Exchange ， Binding



# 三、 SpringBoot 与检索

