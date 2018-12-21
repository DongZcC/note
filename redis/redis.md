# API的理解与使用

## 全局

### 全局命令

#### 1.查看所有键

```bash
keys *
```

keys 命令会将所有键输出 ， 时间复杂度 O(n)

#### 2.键总数

```bash
dbsize
```

返回当前数据库中键的总数，时间复杂度 O(1) 。当Redis中保存了大量键时，线上环境禁止使用Keys

#### 3.检查键是否存在

```bash
exists key
```

如果键存在则返回1 ，不存在则返回0

#### 4.删除键

```bash
del key [key ...]
```

del 是一个通用命令，无论值是什么数据结构类型，del命令都可以讲起删除. 同时 del 命令可以支持删除多个键。

#### 5.键过期

```bash
expire key seconds
```

Redis支持对键添加过期时间，当超过过期时间后，会自动删除键。

**ttl** 命令会返回键的剩余过期时间，它有三种返回值：

* 大于等于0 的整数 ： 键剩余的过期时间
* -1 ： 键没有设置过期时间
* -2 ：键不存在

#### 6.键的数据结构类型

```bash
type key 
```

返回键的类型， 如果键不存在返回 none

type命令返回的当前键的数据结构类型 ，他们分别是 string（字符串）、 hash（哈希）、list（列表）、set（集合）、zset（有序集合） 这些是Redis对外的数据结构。

![1529993666472](C:\Users\dongzc15247.HS\Desktop\note\images\1529993666472.png)



 实际上每种数据结构都有自己底层的内部编码实现。而且是多钟实现，这样Redis会在何时的场景选择合适的内部编码 ，如图所示 。 可以看到每种数据结构都有两种以上的内部编码实现 ，可以通过 object encoding 命令查询内部编码

```bash
object encoding key
```

这样的设计， 有两个好处：

* 可以改进内部编码，对外的数据结构和命令没有影响，这样一旦开发出更优秀的内部编码，无需改动外部数据结构和命令。
* 多种内部编码实现可以在不同场景下发挥各自的优势，例如ziplist比较节省内存，但是在列表元素较多的情况下，性能会有所下降，这时候Redis会根据配置选项将列表类型的内部实现转换为linkedlist



![1529993763025](C:\Users\dongzc15247.HS\Desktop\note\images\1529993763025.png)

### 单线程架构

Redis使用了单线程架构和IO多路复用模型来实现高性能的内存数据库服务。

![1529994021329](C:\Users\dongzc15247.HS\Desktop\note\images\1529994021329.png)

所有的命令在队列中依次执行。

![1529994040329](C:\Users\dongzc15247.HS\Desktop\note\images\1529994040329.png)

![1529994055644](C:\Users\dongzc15247.HS\Desktop\note\images\1529994055644.png)



#### 为什么单线程还可以这么快？

​	通常来讲，单线程的处理能力要比多线程要差， 为什么Redis使用单线程模型，会达到每秒万级别的处理能力呢？ 

* 纯内存访问，Redis将素有数据放在内存中，内存的响应时长大约为100纳秒，这是Redis达到每秒万级别访问的重要基础
* 非阻塞IO ，Redis使用epoll作为IO多路复用的技术实现，再加上Redis自身的事件处理模型将epoll中的连接、读写、关闭都转换为时间，不在网络IO上浪费过多的时间
* 单线程避免了线程切换和 竞态产生的消耗。
  * 单线程简化数据结构和算法的实现
  * 避免了线程切换和竞态产生的消耗



![1529994283302](C:\Users\dongzc15247.HS\Desktop\note\images\1529994283302.png)





## 字符串

### 命令

#### 1.常用命令

（1） 设置值

```bash
set key value [ex seconds] [px milliseconds] [nx | xx]
```

set 命令有几个选项：

* ex  seconds : 为键设置秒级别的过期时间
* px milliseconds ： 为键设置毫秒级别的过期时间
* nx ： 键必须不存在，爱可以设置成功， 用于添加
* xx： 与nx相反，键必须存在才可以设置成功， 用于更新。

除了 set 选项 Redis 还提供了 setnx  setxx 两个命令 。 

setnx 命令为例子， 由于Redis 的单线程命令处理机制，如果有多个客户端同时执行 setnx key value 只有一个客户端可以设置成功， setnx可以作为分布式锁的一种实现方案。

（2） 获取值

```bash
get key
```

​	如果要获取的键不存在 返回 nil

（3）批量设置值

```bash
mset key value [key value ...]
```

（4）批量获取值

```bash
mget key [key ...]
```

（5）计数

```bash
incr key
```

incr命令用于对值做 自增操作，返回结果分为三种情况：

* 值不是整数， 返回错误
* 值是整数， 返回自增后的结果
* 键不存在， 按照值为0 自增， 返回结果为1

除了incr命令， Redis提供了 decr（自减） ， incrby （自增指定数字）、 decrby（自减指定数字）、 incrbyfloat（自增浮点数）

#### 2.不常用命令

略

![1529995507002](C:\Users\dongzc15247.HS\Desktop\note\images\1529995507002.png)



### 内部编码

字符串类型内部编码有三种：

* int ： 8个字节的长整型
* embstr ： 小于等于39个字节的字符串
* raw ： 大于39个字节的字符串

Redis会根据当前值的类型和长度决定使用哪种内部编码实现

### 典型使用场景

#### 1.缓存功能

![1529995851820](C:\Users\dongzc15247.HS\Desktop\note\images\1529995851820.png)

> 与mysql等关系型数据库不同的是， Redis 没有命令空间，也没有对键名称有强制要求（除了不能使用一些特殊字符） 但是设计合理的键名有利于防止键冲突，和项目的可维护性。 
>
> 推荐使用： 业务名： 对象名：id：【属性】 作为键名。 例如mysql的数据库名为vs  ，用户表名为user ，那么对应的键可以用 “vs:user:1” , "vs:user:1:name" 来表示。

#### 2.计数

利用Redis的incr 来实现基础计数功能。

#### 3.共享Session

一个分布式Web服务将用户的Session信息，保存在各自服务器中，这样会出现一个问题， 出于负载均衡的考虑， 分布式服务会将用户的访问均衡到不同的服务器上， 用户刷新一次访问可能发现需要重新登录。



![1529996309564](C:\Users\dongzc15247.HS\Desktop\note\images\1529996309564.png)

#### 4. 限速

短信验证码，多长时间内只能发送5次。可以考虑用Redis 来实现。

![1529996431706](C:\Users\DONGZC~1.HS\AppData\Local\Temp\1529996431706.png)





## 哈希

​	在Redis 中 ， 哈希类型是指简直本身又是一个键值对结构 形如 value = {{field1, value1} , {field2, value2}...} ,Redis 键值对和哈希类型二者关系入下图：

![1530166043686](C:\Users\dongzc15247.HS\Desktop\note\images\1530166043686.png)

### 命令

（1） 设置值

```bash
hset key field value
```

（2）获取值

```bash
hget key field
```

（3）删除field

```bash
hdel key field [field ...]
```

（4）计算field个数

```bash
hlen key
```

（5）批量设置或获取field-value

```bash
hmget key field [field ...]
hmset key field value [field value ...]
```

（6）判断key是否存在

```bash
hexists key field
```

（7）获取所有field

```bash
hkeys key
```

（8）获取所有value

```bash
hvals key
```

（9）获取所有的field-value

```bash
hgetall key
```

> 在使用 hgetall时 ， 如果哈希元素个数比较多，会存在阻塞Redis的可能。如果开发人员只需要获取部分field， 可以使用hmget 如果一定要获取全部 field-value ， 可以使用 hscan 命令， 该 命令会渐进式的遍历哈希类型。

（10） hincrby hincrbyfloat

```bash
hincrby key field
hincrbyfloat key field
```

上述两个命令， 和incrby 和incrybyfloat命令一样， 但是他们的作用域是field

（11）计算value的字符串长度（Redis3.2以上）

```bash
hstrlen key field
```

![1530166492864](C:\Users\dongzc15247.HS\Desktop\note\images\1530166492864.png)

![1530166503861](C:\Users\dongzc15247.HS\Desktop\note\images\1530166503861.png)

### 内部编码

​	哈希类型内部编码有两种：

* ziplist （压缩列表） ： 当哈希元素个数小于 hash-max-ziplist-entries 配置 （默认512个） 、同时所有值都小于hash-max-ziplist-value 配置（默认64字节时） ，Redis会使用ziplist作为哈希的内部实现， ziplist使用更加紧凑的结构实现多个元素的连续存储，所以在节省内存方便比hashtable更加优秀
* hashtable（哈希表）：当哈希类型无法满足ziplist的条件时，Redis会使用hashtable作为哈希的内部实现，因为此时ziplist的读写效率会下降，而hashtable的读写时间复杂度为O(1)



### 使用场景

​	用于对应关系型数据库的表结构

![1530166821080](C:\Users\dongzc15247.HS\Desktop\note\images\1530166821080.png)



## 列表

​	列表（list）类型是用来存储多个有序的字符串。列表中每个字符串称为元素（element），一个列表最多可以存储 2 的 32次方 - 1个元素。在Redis 中可以对列表两端插入（push）和弹出（pop） ， 还可以获取指定范围的元素列表、获取指定索引下标的元素。 列表是一种比较灵活的数据结构，它可以充当栈和队列的角色。

![1530168523321](C:\Users\dongzc15247.HS\Desktop\note\images\1530168523321.png)

![1530168535420](C:\Users\dongzc15247.HS\Desktop\note\images\1530168535420.png)

列表类型有两个特点：

* 列表中元素是有序的，这就意味着可以通过索引下标获取某个元素， 或某个范围内的元素列表
* 列表中元素是可以重复的

### 命令

​	![1530168788423](C:\Users\dongzc15247.HS\Desktop\note\images\1530168788423.png)

![1530169081993](C:\Users\dongzc15247.HS\Desktop\note\images\1530169081993.png)



### 内部编码

列表类型内部编码有两种：

* ziplist（压缩列表）：当类表的元素个数小于 list-max-ziplist-entires 配置（默认512） ，同时列表中每个元素的值都小于list-max-ziplist-value配置时（默认64字节） ，Redis会选用zipList作为列表内部实现来减少内存的使用。
* linkedlist （链表）： 当列表类型无法满足ziplist的条件时，Redis会使用linkedlist作为列表的内部实现。



### 使用场景

#### 1.消息队列

Redis的lpush + brpop 命令组合，即可实现阻塞队列， 生产者客户端使用lrpush ，向列表左侧插入元素， 多个消费者客户端使用brpop命令， 阻塞式的抢占尾部元素。

![1530169531908](C:\Users\dongzc15247.HS\Desktop\note\images\1530169531908.png)

#### 2.文章列表

​	每个用户都有属于自己的文章列表，现需要分页展示文章列类表。此时可以考虑使用类表，因为列表不但是有序的，同事支持按照索引范围获取元素。

​	使用列表类型保存和获取文章列表会存在两个问题

* 如果每次翻页获取的文章个数比较多， 需要执行多长 hgetall操作， 此时可以考虑使用pipeline 批量获取。或者考虑将文章数据序列化为字符串类型，使用meget批量获取
* 分页获取文章列表时，lrange命令在两端性能较好，但是如果列表较大，获取列表中间范围的元素性能会变差，此时可以考虑将列表做耳机拆分。或者使用quicklist内部编码实现。

lpush + lpop = Stack 

lpush + rpop = Queue

lpsh + ltrim = Capped Collection （有限集合）

lpush + brpop = Message Queue





## 集合

​	集合（Set）类型也是用来保存多个字符串的元素，但是和列表类型不一样的是，集合中不允许有重复元素，并且集合中元素是无序的，不能通过索引下标获取元素。

![1530182789856](C:\Users\dongzc15247.HS\Desktop\note\images\1530182789856.png)

### 命令

#### 1.集合内元素

（1）添加元素

```bash
sadd key element [element ...]
```

（2）删除元素

```bash
srem key element [element ...]
```

（3）计算元素个数

```bash
scard key
```

scard的时间复杂度为O（1），他不会遍历集合中的所有元素，而是直接使用Redis的内部变量

（4）判断元素是否在集合中

```bash
sismember key element
```

（5）随机从集合中返回指定个数元素

```bash
srandmember key [count]
```

count是可选参数，如果不写 默认为1 

（6）从集合随机弹出元素

```bash
spop key
```

从Redis3.2版本开始spop也支持 [count]参数

srandmember 和 spop 都是随机从集合中选出元素，二者不同的是spop命令执行后，元素会从集合中删除。

（7）获取所有元素

```bash
smembers key
```

smembers 和 lrange ,hgetall 都属于比较重的命令， 如果元素过多存在阻塞Redis的可能性， 这是可以用sscan来完成。

#### 2.集合间操作

（1）求多个集合的交集

```bash
sinter key [key ...]
```

（2）求多个集合的并集

```bash
sunion key [key ...]
```

（3）求多个集合的差集

```bash
sdiff key [key ...]
```

（4）将交集、并集、差集的结果保存

```bash
sinterstore destination key [key ...]
sunionstore destination key [key ...]
sdiffstore destination key [key ...]
```

​	集合间的运算在元素较多的情况下会比较耗时，所以Redis提供了上面三个命令（原命令 + store ） 将集合间交集、并集、差集的结果保存在destination key中。

​	例如下面的操作将 user:1:follow 和 user:2:follow的交集结果存在 user:1_2:inter中 ， user:1_2:inter本身也是集合类型：

```bash
sinterstore user:1_2:inter user:1:follow user:2:follow
```

![1530183902706](C:\Users\dongzc15247.HS\Desktop\note\images\1530183902706.png)



### 内部编码

集合类型内部编码

* intest（整数集合）： 当集合中的元素都是正数元素 且元素个数小于 set-max-inset-entries配置（默认512个）时， Redis会选用intset来作为集合内部的实现。 减少内存的使用。
* hashtable（哈希表）：当集合类型无法满足intset条件时，Redis会使用hashtable作为集合的内部实现。

### 使用场景

​	集合类型比较典型的使用场景是标签（tag）。

> 用户和标签的关系维护应该在一个事务内执行，防止部分命令失败造成的数据不一致



集合类型场景：

* sadd = Tagging （标签）
* spop / srandmember = Random item （生成随机数， 比如抽奖）
* sadd + sinter = Social Graph （社交需求）



## 有序集合

​	有序集合保留了集合不能有重复元素的特性，但是不用的是，有序集合中的元素可以排序。但是他和列表中使用索引做下标排序依据不同的是，它给每个元素设置一个分数（score) 作为排序的依据。

![1530184720553](C:\Users\dongzc15247.HS\Desktop\note\images\1530184720553.png)

> 有序集合中的元素不能重复，但是 Score 可以重复。



![1530184764462](C:\Users\dongzc15247.HS\Desktop\note\images\1530184764462.png)



### 命令

#### 1.集合内

（1）添加成员

```bash
zadd key score member [score member ...]
```

zadd 命令需要注意：

* Redis3.2版本为zadd命令添加了 nx 、xx、 ch、 incr 四个选项
  * nx : member必须不存在，才可以设置成功， 用于添加
  * xx：member必须存在，才可以设置成功，用于更新
  * ch：返回此次操作后，有序集合元素和分数发生变化的个数
  * incr：对score做增加，相当于后面介绍的zincrby
* 有序集合相比集合提供了排序字段，但是也产生了代价，zadd的时间复杂度为O（log（n）） ，sadd的时间复杂度为O（1）

（2）计算成员个数

```bash\
zcard key
```

（3）计算某个成员分数

```bahs
zscore key member
```

（4）计算成员排名

```bash
zrank key member
zrevrank key member
```

（5）删除成员

```bash
zrem key member [member ...]
```

（6）增加成员的分数

```bash
zincrby key increment member
-- 下面操作为 tom 增加了 9 分
zincrby user:ranking 9 tom
```

（7）返回指定排名范围的成员

```bash
zrange key start end [withscores]
zrevrange key start end [withscores]
```

（8）返回指定分数范围的成员

```bash
zrangebyscore key min max [withscores] [limit offset count]
zrevrangebyscore key max min [withscores][limit offset count]
```

​	其中zrangebyscore按照分数从低到高返回，zrevrangebyscore反之。

![1530185534502](C:\Users\dongzc15247.HS\Desktop\note\images\1530185534502.png)

![1530185558947](C:\Users\dongzc15247.HS\Desktop\note\images\1530185558947.png)

（9）返回指定分数范围的成员个数

```bash
zcount key min max
```

下面操作返回200到221分的成员个数

（10）删除指定排名内的升序元素

```bash
zremrangebyrank key start end
```

下面操作删除第start到第end名的成员：

```bash
zremrangebyrank user:ranking 0 2
```

（11）删除指定分数范围的成员

```bash
zremrangebyscore key min max
```



#### 2.集合间的操作

![1530185843512](C:\Users\dongzc15247.HS\Desktop\note\images\1530185843512.png)



（1）交集

```bash
zinterstore destination mumkeys key [key ...][weights weight [weight ...]] [aggregate sum|min|max]
```

命令参数说明：

* destination：交集计算结果保存到这个键
* numkeys：需要做交集计算键的个数
* key[key...]：需要做交集计算的键
* weight[weight...]：每个键的权重，在做交集计算时，每个键中的每个member会将自己分数乘这个权重，每个键的权重默认是1
* aggregate sum|min|max  ： 计算成员交集后，分值可以按照sum（和）、min（最小值）、max（最大值）做汇总，默认值是sum

下面操作对user：ranking：1 和user：ranking：2做交集，weights和aggregate使用了默认配置，可以看到目标建user：ranking：1_inter2对分值做了sum操作：

![1530186215006](C:\Users\dongzc15247.HS\Desktop\note\images\1530186215006.png)

![1530186244178](C:\Users\dongzc15247.HS\Desktop\note\images\1530186244178.png)



（2）并集

```bash
zunionstore destination mumkeys key [key ...][weights weight [weight ...]] [aggregate sum|min|max]
```

该命令所有参数和zinterstore是一致的，只不过是做并集计算。



![1530186794902](C:\Users\dongzc15247.HS\Desktop\note\images\1530186794902.png)





### 内部编码

有序集合内部编码：

* ziplist（压缩列表）：当有序集合的元素个数小于zset-max-ziplist-entries配置（默认128个），同时每个元素的值都小于 zset-max-ziplist-value配置（默认64字节）时，Redis会用ziplist来作为有序集合的内部实现。
* skiplist（跳表）：当ziplist条件不满足时，有序集合会使用skiplist作为内部实现。



### 使用场景

​	有序集合比较典型的使用场景就是排行榜系统。



## 键管理

### 单个键管理

针对单个建的命令

#### 1.键重命名

```bash
rename key newkey
```

* 由于重命名键期间会执行del命令删除旧的键，如果键对应的值比较大， 会存在阻塞Redis的可能。
* 如果rename和renamenx中的key 和newkey如果是相同的。 Redis3.2版本后会返回有差异。

#### 2.随机返回一个键

```bash
randomkey
```



#### 3.键过期

Redis提供 expire 、 ttl、 expireat、 pexpireat、 pttl、persist等一系列命令

* expire key seconds ：键在seconds秒后过期
* expireat key timestamp：键在秒级时间戳timestamp后过期
* pexpire key milliseconds ： 键在毫秒后过期
* pexpireat key milliseconds-timestamp键在毫秒级时间戳timestamp后过期

无论使用过期时间还是时间戳，秒级还是毫秒级，在Redis内部最终使用的都是pexpireat

在使用Redis相关过期命令时,需要注意：

* 如果expire key 的键不存在， 结果返回为0 
* 如果过期时间为负值，则键会被立即删除 ， 犹如使用del命令一样
* persist命令可以讲键的过期时间清楚
* 对于字符串类型键，执行set命令会去掉过期时间，（这个问题很容易在开发时间别忽视）
* Redis不支持二级数据结构（例如哈希、列表）内部元素的过期功能， 例如不能对一个列表类型的元素做过期时间设置
* setex命令作为set + expire的组合， 不但是原子执行，同时减少了一次网络通讯的时间

#### 4.迁移键

​	迁移键功能非常重要，因为有时候我们只想把部分数据从一个Redis迁移到另一个Redis（例如从生产环境迁移到测试环境），Redis发展历程中提供了 move 、 dump + restore + migrate 三组迁移键的方法。

（1） move	： move命令用于在Redis内部进行数据迁移，Redis内部可以有多个数据库， 彼此在数据上相互隔离的。 move key db 就是把指定的键从源数据库移动到目标数据库中。

![1530685510501](C:\Users\dongzc15247.HS\Desktop\note\images\1530685510501.png)



（2） dump + restore 

```bash
dump key 
restore key ttl value
```

​	dump + restore 可以实现在不同的Redis实例之间进行数据迁移的功能，整个迁移过程分为两步：

* 在源Redis上， dump命令会将键值序列化，格式采用的是RDB格式 （Redis中二进制格式）
* 在目标Redis 上，restore命令将上面序列化的值进行复原，其中ttl参数代表过期时间，如果ttl = 0 代表没有过期时间。

> 注意： 
>
> 1. 整个迁移过程并非原子性的，而是通过客户端分步完成的。
> 2. 迁移过程是开启了两个客户端连接，所以dump结果不是在源Redis和目标Redis之间进行传输。

![1530685816955](C:\Users\dongzc15247.HS\Desktop\note\images\1530685816955.png)



（3）migrate

```bash
migrate host port key | "" destination-db timeout [copy] [replace] [keys key [key]]
```

migrate 命令也是用于在Redis实例间进行数据迁移的，实际上migrate命令就是将 dump、 restore、del命令进行组合，从而简化了操作流程。 migrate命令具有原子性，并且支持迁移多个键的公恩那个，有效的提高了迁移效率。

* host ： 目标Redis的ip地址
* port ：目标Redis的端口
* key | ""： 需要迁移的键，如果要迁移多个键，此处为空字符串。
* destination-db：目标Redis数据库索引， 例如要迁移到 0  号数据库。
* timeout ： 迁移的超时时间（单位为毫秒）
* [copy] : 如果添加此选项，迁移后并不删除源键
* [replace]：如果添加此全向， migrate 不管目标Redis是否存在该键都会正常迁移进行数据覆盖。
* [keys key [key ...]] ：迁移多个键，例如要迁移 key1 ， key2， key3， 此处填写 keys  key1  key2 key3

![1530686785228](C:\Users\dongzc15247.HS\Desktop\note\images\1530686785228.png)



![1530686989675](C:\Users\dongzc15247.HS\Desktop\note\images\1530686989675.png)



### 遍历键

Redis提供两个命令遍历所有的键，分别是keys和scan 

#### 1.全量遍历键

```bash
keys pattern
```

pattern使用glob风格的通配符

* *代表匹配任意字符
* . 代表匹配一个字符
* [] 代表匹配部分字符， [1,3]代表匹配 1， 3  , [1-10] 代表匹配 1 到10 的任意数字
* \x 用来做转义， 例如要匹配星号 ，问号 需要进行转义。

考虑到Redis 的单线程架构，Redis如果包含大量的键，执行keys命令可能会造成Redis阻塞，一般建议不要在生产环境下使用keys命令。但有时候确实遍历键的需求应该怎么办，可以在三种情况使用：

* 在一个不对外提供服务的Redis从节点上执行，这样不会阻塞到客户端的请求，但是会影响主从复制
* 如果确认键值总数确实比较少，可以执行该命令
* 使用scan命令渐进式的遍历所有的键

#### 2.渐进式遍历

Redis从2.8版本后，提供了一个新的命令scan，有效解决keys命令存在的问题。和keys命令执行时会遍历所有键不同，scan采用渐进式遍历的方式来解决keys命令可能带来的阻塞问题，每次scan命令的时间复杂度是O（1），但是要真正实现keys的功能，需要执行多次scan， Redis存储键值对，实际使用的是hashtable的数据结构。

每次执行scan ， 可以想象成只扫描一个字典中的一部分键，直到将字典中所有的键遍历完毕。

```bash
scan cursor [match pattern] [count number]
```

* cursor 是必须参数，是加上cursor是一个游标，第一次遍历从0  开始，每次scan遍历完都会返回当前游标的值，直到游标值为0  ，表示遍历结束
* mattch pattern 是可选参数，他的作用是做模式匹配，这点和keys的匹配模式很闲
* count number 是可选参数，他的作用是表名每次要遍历的键的个数，默认值是 10 ， 此参数可以适当增大。

从 0 开始使用scan命令， 每次都会返回一个游标， 当游标重新变为0 的时候，代表遍历结束。

除了scan意外，Redis提供了面向哈希类型、集合类型、有序集合的扫描遍历命令，解决诸如hgetall, smembers ,zrange可能产生的阻塞问题， 对应的命令分别是 hscan 、 sscan 、zscan 他们的用法和scan基本类似。

![1530687634561](C:\Users\dongzc15247.HS\Desktop\note\images\1530687634561.png)



### 数据库管理

Redis提供了几个面向Redis数据库的操作，它们分别是dbsize、 select  、flushdb/flushall命令

#### 1.切换数据库

```bash
select dbIndex 
```

​	许多关系型数据库，例如MySQL支持在一个实例下有多个数据库存在的，但是与关系型数据库用字符来区分不同数据库名不同，Redis知识用数字作为多个数据库的实现，Redis默认配置中有16个数据库。

​	Redis3.0开始已经逐渐弱化这个功能，例如Redis分布是实现Redis Cluster 只允许使用 0 号数据库，只不过为了向下兼容老版本的数据库功能，该功能没有完全废弃掉，

* Redis是单线程的， 如果使用多个数据库， 那么这些数据库仍然是使用一个CPU ， 彼此之间还是会收到影响的。
* 多数据库的使用方式，会让调试和运维不同业务的数据变的困难，例如有一个慢查询的存在，依然会影响其他数据库，这样会使别的业务定位问题非常困难。
* 部分Redis的客户端根本就不支持这种方式， 即使支持，在开发的时候来回切换数字形式的数据库，很容易弄乱。

如果想要使用多个数据库功能，完全可以在一台机器上部署多个Redis实例，彼此用端口来做区分。因为现代计算机通常是有多个CPU的，这样即保证了业务之间不会受到影响， 又合理的使用了CPU资源。

#### 2.flushdb/flushall

​	命令用于清除数据库，两者的区别是flushdb只清楚当前的数据库， flushall会清除所有的数据库。

flushdb/flushall命令可以非常方便的清理数据，但是也带来两个问题

* 会将所有数据清楚，一旦误操作后后果不堪设想。
* 如果当前数据库键值比较多，会存在阻塞Redis的可能性

因此使用一定要小心谨慎。



# 扩展功能

## 慢查询分析

​	许多存储系统（例如MySQL）提供慢查询日志，帮助开发和运维人员，定位系统存在的慢操作。所谓慢查询日志就是系统在命令执行前后计算每条命令的执行时间，当超过预定阈值，就将这条命令的相关信息记录下来，Redis也提供了类似的功能。

​	慢查询只统计步骤3  （执行命令）

![1530691719141](C:\Users\dongzc15247.HS\Desktop\note\images\1530691719141.png)

### 慢查询的两个配置参数

​	Redis提供了slowlog-log-slower-than  和 slowlog-max-len 配置来解决这两个问题。 一个是预设阈值，单位是微秒，默认是10000 。 （1s = 1000ms = 1000 000 微秒）

​	当slowlog-log-slower-than = 0 会记录所有的命令， slowlog-log-slower-than < 0  对于任何命令都不会进行记录。Redis提供了一个列表来存储慢查询日志， slowlog-max-len就是该列表的最大长度。一个新的命令满足慢查询条件时，将被插入到这个列表中，当慢查询日志列表已处于最大长度时，最早插入的一个命令将会从列表中移出。

​	Redis中有两种修改配置的方法，一种是修改配置文件，另一种是使用config set 命令动态修改。

​	如果想要将Redis配置持久化到本地配置文件，需要执行 config rewrite 命令。

​	虽然慢查询日志是存放在Redis内存列表中的，但是Redis并没有暴露这个列表的键，而是通过一组命令来实现对慢查询日志的访问和管理

（1） 获取慢查询日志

showlog get [n]

![1530692083788](C:\Users\dongzc15247.HS\Desktop\note\images\1530692083788.png)



（2）获取慢查询日志列表当前的长度

```bash
slowlog len
```

（3）慢查询日志重置

```bash
slowlog reset
```

## Redis shell

​	Redis提供了redis-cli , redis-server , redis-benchmark 等Shell工具

### redis-cli详解

#### 1. -r

-r （repeat）选项代表将命令执行多次

#### 2. -i

-i （interval）选项代表每隔几秒钟执行一次命令， 但是 -i 选项必须 和 -r 选项一起使用 ， 单位是秒，不支持毫秒为单位

#### 3. -x

-x选项代表标准输入（stdin）读取数据作为redis-cli的最后一个参数，例如下面的操作会将字符串world作为set hello的值

```bash
echo "world" | redis-cli -x set hello
```

#### 4. -c

-c （cluster）选项是连接 Redis Cluster节点需要使用的  -c 选项可以防止 moved 和ask 异常

#### 5. -a

如果Redis配置了密码， 可以用 -a（auth）选项。

#### 6. --scan 和 --pattern

--scan 和--pattern 选项用于扫描指定模式的键，相当于使用scan命令

#### 7. --slave

--slave选项是把当前客户端模拟成当前Redis节点的从节点， 可以用来获取当前Redis节点的更新操作。

下面开启第一个客户端，使用 --salve选项

```bash
redis-cli --slave
```

再开启另一个客户端做一些更新操作

```bash
redis-cli
```

第一个客户端会收到Redis节点的更新操作

#### 8. --rdb

--rdb选项会请求Redis实例生成并发送RDB持久化文件，保存在本地。可是用它做持久化文件的定期备份。

#### 9. --pipe

-pipe选项用于将命令封装成Redis通信协议定义的数据格式，批量发送给Redis执行。

#### 10. --bigkeys

--bigkeys选项使用scan命令对Redis的键进行采样，从中找到内存占用比较大的键值，这些键可能是系统的瓶颈

#### 11. --eval

--eval 选项用于执行指定Lua脚本

#### 12. --latency

latency有三个选项，分别是 --latency ， --latency-history 、 --latency-dist 可以检测网络延迟

#### 13. --stat

--stat选项可以实时获取Redis的重要统计信息

#### 14 --raw 和 --no-raw

--no-raw选项是要求命令返回结果必须是原始格式， --raw 返回格式化后的结果

### redis-server详解

​	redis-server除了启动Redis外，还有一个 --test-memory选项。 可以用来检测当前操作系统能否稳定的分配指定容量的内存给Redis  ， 通过这种检测可以有效避免因为内存为题造成Redis崩溃。 例如下面检测当前操作系统能否提供1G的内存给Redis 

```bash
redis-server  --test-memory 1024
```

整个内存检测的时间比较长，当输出 passed  this test时， 说明内存检测完毕。

### redis-benchmark 详解

​	redis-benchmark可以为Redis做基准性能测试，它提供了很多选项帮助开发和运维人员测试Redis的相关性能。

#### 1. -c

-c（clients）选项代表客户端的并发数量（默认50）

#### 2.-n <requests>

-n（num）选项代表客户端请求总量（默认是10000）

例如 redis-benchmark -c 100 -n 20000 代表100哥客户端同事请求Redis  一共执行 20000次。

#### 3. -q

#### 4. -r

random 向Redis中插入更多的键，

```bash
redis-benchmark -c 100 -n 20000 -r 10000
```

-r 10000 代表只对后四位做随机处理（-r 不是随机数的个数）

#### 5. -P

-P选项代表每个请求pipeline的数据量（默认为1）

#### 6. -k<boolean>

-k 选项代表客户端是否使用 keepalive 1 为使用，  0 为不使用 ， 默认值为1

#### 7. -t

-t选项可以对指定命令进行基准测试

#### 8. --csv

--csv选项会将结果按照csv格式输出，便于后续处理，如导出到Excel等。

## Pipeline

### 概念

Redis客户端执行一条命令分为以下四个过程

1） 发送命令

2） 命令排队

3） 命令执行

4） 返回结果

其中 1） + 4） 称为 Round Trip Time （RTT 往返时间）

Redis提供了批量操作命令， （例如 mget 、 mset）有效的解约RTT 。 但是大部分命令是不支持批量操作的 ，例如要执行 n 次  hgetall ，并没有 mhgetall命令存在， 需要消耗 n 次 RTT 。 

Pipeline （流水线）机制能改善上面这类问题， 它能将一组Redis命令进行组装， 通过一次RT传输给Redis 再讲这组Redis命令的执行结果按顺序返回给客户端。

### 原生命令与Pipeline对比

可以使用Pipeline模拟出批量操作的效果，但是在使用时，要注意它与原生批量命令的区别

* 原生批量命令是原子的，Pipeline是非原子的
* 原生批量命令是一个命令对应多个 key ， Pipeline支持多个命令
* 原生批量命令是Redis服务端支持实现的，Pipeline 需要服务端和客户端共同实现。



## 事务与Lua	

​	Redis提供了简单的事务功能， 将一组需要一起执行的命令放到 multi 和exec 两个命令之间。 multi 命令代表事务开始， exec命令代表事务结束，它们之间的命令是原子顺序执行的。（Redis 不支持回滚功能， 还是有点问题的）

​	需要实现复杂的事务， 可以使用Lua脚本

## Bitmaps

### 数据结构模型

现代计算机用二进制（位）作为信息的基础单位，一个字节等于8位。“big”字符串就是由三个字节组成，实际计算机存储时，用二进制表示。

![1530771188356](C:\Users\dongzc15247.HS\Desktop\note\images\1530771188356.png)

​	许多开发语言提供了操作位的功能，合理的使用可以有效提高内存使用率和开发效率。

* Bitmaps本身不是一种数据结构，实际上它就是字符串，但是可以对字符串的位进行操作
* Bitmaps单独提供了一套命令，所以在Redis中使用Bitmaps和使用字符串的方法不太相同。可以把Bitmaps想象成一个以位为单位的数组，数组的每个单元只能存储 0 和 1，数组的下表在Bitmaps中叫做偏移量。

### 命令

#### 1.设置值

```bash
setbit key offset value
```

​	设置键的第offset个位的值（从0算起），假设现在有20个用户，userId = 0, 5 , 11, 15, 19的用户对网站进行了访问，那么就初始化Bitmaps如图

![1530771396916](C:\Users\dongzc15247.HS\Desktop\note\images\1530771396916.png)

#### 2.获取值

```bash
gitbit key offset
```

​	获取键的第offset位的值（从0开始计算）

#### 3.获取Bitmaps指定范围值为1 的个数

```bash
bitcount [start][end]
```

#### 4.Bitmaps间的运算

```bash
bitop op destkey key [key ...]
```

​	bitop是一个复合操作，它可以做多个Bitmaps的 and （交集） 、 or（并集） 、 not（非）、xor（异或）操作并将结果保存在destkey 中。

#### 5.计算Bitmaps中第一个值为targetBit的偏移量

```bash
bitpos key targetBit [start][end]
```

下面操作计算2016-04-04当前访问网站的最小用户id：

```bash
bitpos unique:users:2016-04-04 1
```

### Bitmaps分析

假设网站用户有一亿用户， 每天独立访问的用户有五千万，如果每天用集合类型和Bitmasp分别存储活跃用户可以得到表： 但是如果网站的用户比较少， 那么需要占用的内存反而多了。

![1530771753903](C:\Users\dongzc15247.HS\Desktop\note\images\1530771753903.png)



## HyperLogLog

​	HyperLogLog并不是一种新的数据结构（实际类型为字符串类型），而是一种基数算法，通过HyperLogLog可以利用绩效的内存空间，完成独立总数的同级，数据集可以是IP、 Email、ID等。

### 1.添加

```bash
pfadd key element[element ...]
```

### 2.计算独立用户数

```bash
pfcount key [key ...]
```

### 3.合并

```bash
pfmerge destkey sourcekey [sourcekey ...]
```



HyperLogLog内存占用量非常小，但是存在错误率，开发者在进行数据结构选型时，只需要确认如下两条即可

* 只为了计算独立总数，不需要获取单条数据
* 可以容忍一定误差率

## 发布订阅

![1530772437671](C:\Users\dongzc15247.HS\Desktop\note\images\1530772437671.png)

### 命令

Redis主要提供了发布消息、订阅频道、取消订阅以及按照模式订阅和取消订阅等命令

#### 1.发布消息

```bash
publish channel message
```

#### 2.订阅消息

```bash
subscribe channel [channel ...]
```

* 客户端在执行订阅命令之后进入了订阅状态， 只能接收subscribe 、 psubscribe 、 unsubscribe 、 punsubscribe 四个命令
* 新开启的订阅客户端，无法收到该频道之前的消息 ， 因为Redis不会对发布的消息进行持久化。

> 与很多专业的消息队列系统 （kafka \ RocketMQ）相比，Redis的发布订阅略显粗糙，例如无法实现消息堆积和回溯，但胜在足够简单，如果当前场景可以容忍这缺点， 也是一个不错的选择

#### 3.取消订阅

```bash
unsubcribe [channel [channel ...]]
```

#### 4.按照模式订阅和取消订阅

```bash
psubscribe pattern [pattern]
punsubscribe [pattern [pattern ...]]
```

#### 5.查看订阅

（1）查看活跃的频道

```bash
pubsub channels [pattern]
```

所谓活跃的频道，是指当前频道至少有一个订阅者

（2）查看频道订阅数

```bash
pubsub numsub [channel ...]
```

（3）查看模式订阅数

```bash
pubsub numpat 
```

### 使用场景

聊天室、公告牌、服务之间利用消息解耦等



## GEO

Redis3.2版本提供了GEO（地理信息定位）功能， 支持存储地理位置信息来实现诸如附近位置、摇一摇这类依赖于地理位置信息的功能。





# 客户端

## 客户端通信协议

Redis定制了RESP（REdis Serialization Protocol , Redis序列化协议） 实现客户端与服务端的正常交互， 这种协议简单高效，既能够被机器解析，又容易被人类识别。

#### 1.发送命令格式

RESP的规定一条命令格式如下， CRLF 代表 "\r\n"

```bash
*<参数数量> CRLF
$<参数1的字节数量> CRLF
<参数1> CRLF
...
$<参数N的字节数量> CRLF
<参数N> CRLF
```

#### 2.返回结果格式

Redis的返回结果类型分为以下五种

* 状态回复： 在RESP中第一个字节为 “+”
* 错误回复：在RESP中第一个字节为“"-"
* 整数回复：在RESP中第一个字节为“：”
* 字符串回复：在RESP中第一个字节为“$“
* 多条字符串回复：在RESP中第一个字节为“*”

![1530788603331](C:\Users\dongzc15247.HS\Desktop\note\images\1530788603331.png)



## Java客户端Jedis



### 获取Jedis

直接在项目中加入Maven依赖

```xml
<dependency>
	<groupId>redis.clients</groupId>
	<artifactId>jedis</artifactId>
	<version>2.8.2</version>
</dependency>
```

### Jedis的基本使用方法

```java
Jedis jedis = null;
try {
	jedis = new Jedis("127.0.0.1", 6379);
	jedis.get("hello");
} catch (Exception e) {
	logger.error(e.getMessage(),e);
} finally {
	if (jedis != null) {
		jedis.close();
	}
}


// 1.string
// 输出结果： OK
jedis.set("hello", "world");
// 输出结果： world
jedis.get("hello");
// 输出结果： 1
jedis.incr("counter");
// 2.hash
jedis.hset("myhash", "f1", "v1");
jedis.hset("myhash", "f2", "v2");
// 输出结果： {f1=v1, f2=v2}
jedis.hgetAll("myhash");
// 3.list
jedis.rpush("mylist", "1");
jedis.rpush("mylist", "2");
jedis.rpush("mylist", "3");
// 输出结果： [1, 2, 3]
jedis.lrange("mylist", 0, -1);
// 4.set
jedis.sadd("myset", "a");
jedis.sadd("myset", "b");
jedis.sadd("myset", "a");
// 输出结果： [b, a]
jedis.smembers("myset");
// 5.zset
jedis.zadd("myzset", 99, "tom");
jedis.zadd("myzset", 66, "peter");
jedis.zadd("myzset", 33, "james");
// 输出结果： [[["james"],33.0], [["peter"],66.0], [["tom"],99.0]]
jedis.zrangeWithScores("myzset", 0, -1);

```

参数除了可以是字符串，Jedis还提供了字节数组的参数：

```java
public String set(final String key, String value)
public String set(final byte[] key, final byte[] value)
public byte[] get(final byte[] key)
public String get(final String key)
```

### Jedis连接池的使用方法

​	上面的方法是直连方式，所谓直连是指Jedis每次都会新建TCP连接，使用后再断开连接，对于频繁访问Redis的场景显然不是搞笑的使用方式。

​	生产环境中一般使用连接池的方式对Jedis连接进行管理，所有Jedis对象预先放在池子中JedisPool, 每次需要连接Jedis只需要在池子中借， 完了之后再归还

![1530789032100](C:\Users\dongzc15247.HS\Desktop\note\images\1530789032100.png)





![1530789050846](C:\Users\dongzc15247.HS\Desktop\note\images\1530789050846.png)



​	Jedis提供了JedisPool这个类作为对Jedis的连接池，同时使用了Apache通用对象池工具 common-pool作为资源管理工具

​	1） Jedis连接池（通常JedisPool是单例的）

```java
// common-pool连接池配置， 这里使用默认配置， 后面小节会介绍具体配置说明
GenericObjectPoolConfig poolConfig = new GenericObjectPoolConfig();
// 初始化Jedis连接池
JedisPool jedisPool = new JedisPool(poolConfig, "127.0.0.1", 6379);
```

​	2）获取Jedis对象不再是直接生成一个Jedis对象进行直连，而是从池中获取 (这里Jedis.close方法已经判断了连接池)

```java
Jedis jedis = null;
try {
	// 1. 从连接池获取jedis对象
	jedis = jedisPool.getResource();
	// 2. 执行操作
	jedis.get("hello");
} catch (Exception e) {
	logger.error(e.getMessage(),e);
} finally {
	if (jedis != null) {
		// 如果使用JedisPool， close操作不是关闭连接， 代表归还连接池
		jedis.close();
	}
}
```

连接池的配置如下：

```java
GenericObjectPoolConfig poolConfig = new GenericObjectPoolConfig();
// 设置最大连接数为默认值的5倍
poolConfig.setMaxTotal(GenericObjectPoolConfig.DEFAULT_MAX_TOTAL * 5);
// 设置最大空闲连接数为默认值的3倍
poolConfig.setMaxIdle(GenericObjectPoolConfig.DEFAULT_MAX_IDLE * 3);
// 设置最小空闲连接数为默认值的2倍
poolConfig.setMinIdle(GenericObjectPoolConfig.DEFAULT_MIN_IDLE * 2);
// 设置开启jmx功能
poolConfig.setJmxEnabled(true);
// 设置连接池没有连接后客户端的最大等待时间(单位为毫秒)
poolConfig.setMaxWaitMillis(3000);
```

![1530789232542](C:\Users\dongzc15247.HS\Desktop\note\images\1530789232542.png)



### Jedis中Pipeline的使用方式

```java
public void mdel(List<String> keys) {
	Jedis jedis = new Jedis("127.0.0.1");
	// 1)生成pipeline对象
	Pipeline pipeline = jedis.pipelined();
	// 2)pipeline执行命令， 注意此时命令并未真正执行
	for (String key : keys) {
		pipeline.del(key);
	}
	// 3)执行命令
	pipeline.sync();
}
```



* 利用jedis对象生成一个pipeline对象， 直接可以调用 jedis.pipelined（ ）    
* 将del命令封装到pipeline中， 可以调用pipeline.del（ String key） ， 这个 方法和jedis.del（ String key） 的写法是完全一致的， 只不过此时不会真正的 执行命令    
* 使用pipeline.sync（ ） 完成此次pipeline对象的调用    
* 除了pipeline.sync（ ） ， 还可以使用pipeline.syncAndReturnAll（ ） 将 pipeline的命令进行返回    



### Jedis的Lua脚本



## 客户端管理

略





# 持久化

​	Redis支持RDB和AOF两种持久化机制，持久化功能有效的避免因进程退出造成的数据对视问题，当下次重启时利用之前迟秋华的文件， 即可实现数据恢复。





# 复制

​	在分布式系统中为了解决单点的问题，通常会把数据复制多个副本部署到其他机器，满足故障恢复和负载均衡的需求。

## 配置

### 建立复制

​	参与复制的Redis实例划分为主节点（master）和从节点（slave）。默认情况下Redis都是主节点，每个从节点只能有一个主节点， 而主节点可以同时具有多个从节点。复制的数据流是单向的，只能由主节点复制到从节点，配置复制的方式有以下三种：

1）在配置文件中加入 slaveof{masterHost}{masterPort} 随Redis的启动生效

2）在redis-server启动命令后 加入 --slaveof{masterHost}{masterPort} 生效

3）直接使用命令 slaveof{masterHost}{masterPort} 生效

```bash
slaveof 127.0.0.1 6379
```

slaveof本身是异步命令， 执行slaveof命令时，节点只保存主节点信息后返回，后续复制流程在节点内部异步执行。主从节点成功建立后，可以使用 info replication 命令查看复制相关状态

![1531365650615](D:\工作文档\note\redis\1531365650615.png)

### 断开复制

​	slaveof命令不但可以建立复制，还可以在从节点执行 slaveof no one 来断开与主节点的复制关系。

断开复制主要流程：

* 断开与主节点复制关系
* 从节点晋升为主节点

从节点断开复制后，并不会抛弃原有数据，只是无法再获取主节点上的数据变化

通过slaveof命令还可以实现切主操作。所谓切主是指把当前从节点对主节点的复制，切换到另一个主节点， 执行slaveof{newMasterIP}{newMasterPort}

切主操作流程：

* 断开与旧主节点的复制㽑
* 与新主节点建立复制关系
* 删除从节点当前所有数据
* 对新主节点进行复制操作。



### 安全性

对于数据比较重要的节点，主节点会通过设置requirepass参数进行密码验证，这是所有客户端访问必须使用auth命令实行校验。

### 只读

默认情况下， 从节点使用 slave-read-only=yes配置为只读模式。由于复制只能从主节点到从节点，对于从节点的任何修改主节点都无法感知，修改从节点数据会造成主从数据不一致。

### 传输延迟

​	主从节点一般部署子啊不同机器上，复制时的网络延迟就成为需要考虑的问题。Redis提供repl-disable-tcp-nodelay参数用于控制是否关闭TCP_NODELAY 默认关闭

* 当关闭时，主节点产生的命令数据无论大小都会及时的发送给从节点，这样主从之间的延迟会变小，单增加了网络带宽的消耗，适用于主从之间网络环境良好的场景
* 当开启时，主节点会合并较小的TCP数据包从而节省带宽。



## 拓扑

​	Redis的复制拖布结构可以支持单层或多层复制关系，根据拓扑复杂性可以分为： 一主一从， 一主多从 ， 树状主从结构。



![1531377768500](D:\工作文档\note\images\1531377768500.png)



### 一主多从

星型拓扑结构，使得应用端可以利用多个从节点实现读写分离。对于读占比比较大的场景 ，可以把读命令发送到从节点来分担主节点压力。同时在日常开发中，如果需要执行一些耗时命令：keys \ sort 等，可以在其中一台从节点上执行。

![1531378066775](D:\工作文档\note\images\1531378066775.png)



### 树状主从结构

树状主从结构（树状拓扑结构）使得从节点不但可以复制主节点数据，同时可以作为其他从节点的主节点，继续向下层复制。通过引入复制中间层， 可以有效降低主节点负载和需要传送给从节点的数据量。

![1531378154731](D:\工作文档\note\images\1531378154731.png)



## 原理

### 复制过程

在从节点执行slaveof命令后，复制过程便开始运作，

* 保存主节点信息
* 主从建立socket连接
* 发送ping命令
* 权限验证
* 同步数据集
* 命令持续复制

