## 二、配置文件

### 1、配置文件

application.properteis

application.yml

都可以作为全局的配置文件，修改一些**默认配置**。

### 2、 YAML语法

#### 1、基本语法

k: (空格)v 的写法，来表示一组键值

```yaml
server:
 port: 8081
```

属性和值也是大小写敏感

#### 2、值的写法

**字面量：普通的值（数字，字符串，布尔）**

​	k: v： 字面直接来写；

​	字符串默认不用加上单引号或者双引号；

​	"": 双引号 ： 不会转译字符串里面的特殊字符；特殊字符会作为本身想表示的意思

​		name: "zhangsan \n lisi"  ： 输出： zhangsan 换行 lisi

​	'': 单引号 ： 会转译特殊字符，特殊字符最终会被转换为一个普通的字符串输出

​		name: "zhangsan \n lisi"  ： 输出： zhangsan \n isi

**对象、Map（属性和值）（键值对）**

​	对象还是 k： v的方式  嵌套.

```yaml
friends:
	lastName: zhangsan
	age: lisi
```

​	行内写法：

```yaml
friends: {laseName: zhangsan, age: 18}
```



**数组（List、Set）**

用 - 值 表示数组中的一个元素

```yam
pets: 
	- cat
	- dog
	- pig
```

行内写法:

```yaml
pets: [cat, dog, pig]
```

### 3、配置文件值注入

application.yaml:

```yaml
person:
  lastName: zhangsan
  age: 18
  boss: false
  birth: 2017/12/12
  maps: {k: 1, v: 2}
  lists:
    - dog
    - cat
  dog:
    name: z
    age: 2
```

JavaBean:

```java
package com.learn.bean;

import lombok.Getter;
import lombok.Setter;
import lombok.ToString;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.stereotype.Component;

import java.util.Date;
import java.util.List;
import java.util.Map;

/**
 * 将配置文件中的配一个属性的值，映射到这个组件中，
 * @ConfigurationProperties 告诉springboot 将奔雷中的所有属性和配置文件中的相关配置进行绑定
 *  默认从全局配置文件中获取值。
 *  prefix = "person" ， 配置文件中下面的哪个属性进行映射.
 *  <br>
 *      只有这个组件是容器中的组件时 ，才能提供@ConfigurationProperties的功能
 */
@Getter
@Setter
@ToString
@Component
@ConfigurationProperties(prefix = "person")
public class Person {
    private String lastName;

    private Integer age;

    private Boolean boss;

    private Date birth;

    private Map<String, Object> maps;

    private List<Object> lists;

    private Dog dog;
}

```

可以导入配置文件处理器，重新运行springboot 生成metadata文件，以后编写配置就可以给予提示

```xml
		<dependency>
			<groupId>org.springframework.boot</groupId>
			<artifactId>spring-boot-configuration-processor</artifactId>
			<optional>true</optional>
		</dependency>
```

#### 1、properties 配置文件在IDEA中默认UTF-8会存在乱码

因为properties文件需要以ASCII编码 , 在file -> settings -> file encoding 中配置在运行时 transfer ascii

#### 2、 @ConfigurationProperties 和@ Value 注解比较

|                                 | @ConfigurationProperties                   | @Value       |
| ------------------------------- | ------------------------------------------ | ------------ |
| 功能上                          | 批量注入配置文件中的属性，只需要制定perfix | 一个一个指定 |
| 松散绑定(松散语法  大写  - , _) | 支持                                       | 不支持       |
| SPEL                            | 不支持                                     | 支持         |
| JSR303数据校验                  | 支持                                       | 不支持       |
| 复杂类型封装                    | 支持                                       | 不支持       |

配置文件，yml或 properties都可以获取到值；

如果说，只是在某个业务逻辑中需要获取一下配置文件中的某项值，就使用@Value注解；

如果说，专门编写一个JavaBean，来和配置文件进行映射，需要使用@ConfigurationProperties；

#### 3、配置文件注入值校验

遵循jsr规范. 通过@Validated 注解校验 .

#### 4、@PropertySource & @ImportResource

@PropertySource加载指定的配置文件； 由于@ConfigurationProperties默认只加载全局的配置文件， 这两个注解配合起来使用的话， 就可以加载指定位置的配置文件。 

这个注解也可以和@Value 配合使用。 并且可以指定编码格式。可以解决上面的Unicode编码问题。

```java
/**
 * 将配置文件中的配一个属性的值，映射到这个组件中，
 * @ConfigurationProperties 告诉springboot 将奔雷中的所有属性和配置文件中的相关配置进行绑定
 *  prefix = "person" ， 配置文件中下面的哪个属性进行映射.
 *  <br>
 *      只有这个组件是容器中的组件时 ，才能提供@ConfigurationProperties的功能
 */
@Getter
@Setter
@ToString
@Component
@PropertySource(value = {"classpath:person.properties"})
@ConfigurationProperties(prefix = "person")
public class Person {

    /**
     * <bean class="person">
     *   <property name="lastName" value="字面量"/ ${key} 从环境变量， 配置文件中获取值 /#{spel} ></property>
     * </bean>
     */
    // @Value("#{person.lastName}")
    private String lastName;

    // @Value("#{11 * 2}")
    private Integer age;

    // @Value("true")
    private Boolean boss;

    private Date birth;

    private Map<String, Object> maps;

    private List<Object> lists;

    private Dog dog;
}
```

@ImportResource ： 导入Spring的配置文件，让配置文件里面的内容生效。

SpringBoot中，没有扫描自己配置文件，如果想让Spring配置文件生效，加载进来； 需要把@ImportResource加到配置类中；

```XML
@ImportResource(locations = {"classpath:beans.xml"})

```

SpringBoot推荐给容器中添加组件的方式：推荐使用全注解的方式

1. 配置类  === Spring配置文件

2. 使用@Bean的方式给容器中添加组件

   ```java
   /**
    *  @Configuration 指明当前类是一个配置类； 就是来代替之前的Spring配置文件
    *
    *  在配置文件中用 <bean> </bean> 标签添加组件
    */
   @Configuration
   public class MyAppConfig {
   
       // 将方法的返回值添加到容器中；容器中这个组件默认的id就是方法名
       @Bean
       public HelloService helloService() {
           return new HelloService();
       }
   }
   ```

### 4、配置文件占位符

#### 1、 随机数

```java
${random.value}  ${random.int} ${random.long} ${random.int(10)} ${random.int[1024,65535]}
```



#### 2、 占位符获取之前的配置，如果没有可以使用 ： 指定默认值

```properties
person.last-name=lisi
person.age=12
person.birth=2017/12/15 ${person.last-name : "hello"}
person.boss=true
```

### 5、 Profile

Profile是Spring对于不同环境提供不同配置的功能支持，可以通过激活、指定参数等方式快速切换环境

#### 1、 多Profile文件

我们在主配置文件编写的时候，文件名可以是， application-{profile}.properties  / yml

默认使用application.properties的配置。

1. 在配置文件中，指定 spring.profiles.active = {profile}  来激活  

#### 2、 yml 多文档块

```yaml
server:
  port: 8081

spring:
  profiles:
    active: dev
  
---
server:
  port: 8082
spring:
  profiles: dev
  
---

server:
  port: 8083
spring:
  profiles: prod

```

#### 3、 激活指定profile

命令行：

* --spring.profiles.activce=dev

虚拟机：

* -Dspring.profiles.active=dev

### 6、配置文件加载位置

springboot启动会扫描一下位置的application.properteis或者application.yml文件作为Springboot默认配置文件

- file:/config
- file:/
- classpath:/config
- classpath:/

以上是按照**优先级从高到低** 的顺序，所有位置的文件都会被加载，高优先级的配置内容会覆盖低优先级的配置内容 ； 从四个位置都会加载，互补配置。

**也可以通过配置spring.config.location来改变默认配置**

这个是项目打包好之后，通过命令行参数指定，也是一个互补配置.

### 7、外部配置的加载顺序

Springboot 也可以从以下位置加载配置 ： **优先级从高到低**

1. [Devtools global settings properties](https://docs.spring.io/spring-boot/docs/2.0.2.RELEASE/reference/htmlsingle/#using-boot-devtools-globalsettings) on your home directory (`~/.spring-boot-devtools.properties` when devtools is active).
2. [`@TestPropertySource`](https://docs.spring.io/spring/docs/5.0.6.RELEASE/javadoc-api/org/springframework/test/context/TestPropertySource.html) annotations on your tests.
3. [`@SpringBootTest#properties`](https://docs.spring.io/spring-boot/docs/2.0.2.RELEASE/api/org/springframework/boot/test/context/SpringBootTest.html) annotation attribute on your tests.
4. Command line arguments.
5. Properties from `SPRING_APPLICATION_JSON` (inline JSON embedded in an environment variable or system property).
6. `ServletConfig` init parameters.
7. `ServletContext` init parameters.
8. JNDI attributes from `java:comp/env`.
9. Java System properties (`System.getProperties()`).
10. OS environment variables.
11. A `RandomValuePropertySource` that has properties only in `random.*`.

**优先加载带profile后缀的**

**由jar包外部的加载到jar内部的**

1. [Profile-specific application properties](https://docs.spring.io/spring-boot/docs/2.0.2.RELEASE/reference/htmlsingle/#boot-features-external-config-profile-specific-properties) outside of your packaged jar (`application-{profile}.properties` and YAML variants).
2. [Profile-specific application properties](https://docs.spring.io/spring-boot/docs/2.0.2.RELEASE/reference/htmlsingle/#boot-features-external-config-profile-specific-properties) packaged inside your jar (`application-{profile}.properties` and YAML variants).
3. Application properties outside of your packaged jar (`application.properties` and YAML variants).
4. Application properties packaged inside your jar (`application.properties` and YAML variants).
5. [`@PropertySource`](https://docs.spring.io/spring/docs/5.0.6.RELEASE/javadoc-api/org/springframework/context/annotation/PropertySource.html) annotations on your `@Configuration` classes.
6. Default properties (specified by setting `SpringApplication.setDefaultProperties`).

 

### 8、自动配置原理

#### 1、原理

配置文件到低能写什么？ 怎么写？ 

[配置文件能配置的属性参考](https://docs.spring.io/spring-boot/docs/2.0.2.RELEASE/reference/htmlsingle/#common-application-properties)

自动配置的原理：

1）.SpringBoot启动的时候，加载主配置类，开启了自动配置功能@EnableAutoConfiguration

2）.@EnableAutoConfiguration 作用：

* 利用  AutoConfigurationImportSelector.class 导入一些组件
* 可以查看 selectImports 方法内容。 
* List<String> configurations = getCandidateConfigurations(annotationMetadata,      attributes); 
* 扫描所有jar包类路径下，找到/META-INFO/spring.factories 把扫描到的文件内容，包装成一个properties对象， 从properties ， 从Properties对象中获取EnableConfiguration.class 类名对应的值.

 ```properties
# Auto Configure
org.springframework.boot.autoconfigure.EnableAutoConfiguration=\
org.springframework.boot.autoconfigure.admin.SpringApplicationAdminJmxAutoConfiguration,\
org.springframework.boot.autoconfigure.aop.AopAutoConfiguration,\
org.springframework.boot.autoconfigure.amqp.RabbitAutoConfiguration,\
org.springframework.boot.autoconfigure.batch.BatchAutoConfiguration,\
org.springframework.boot.autoconfigure.cache.CacheAutoConfiguration,\
org.springframework.boot.autoconfigure.cassandra.CassandraAutoConfiguration,\
org.springframework.boot.autoconfigure.cloud.CloudAutoConfiguration,\
org.springframework.boot.autoconfigure.context.ConfigurationPropertiesAutoConfiguration,\
org.springframework.boot.autoconfigure.context.MessageSourceAutoConfiguration,\
org.springframework.boot.autoconfigure.context.PropertyPlaceholderAutoConfiguration,\
org.springframework.boot.autoconfigure.couchbase.CouchbaseAutoConfiguration,\
org.springframework.boot.autoconfigure.dao.PersistenceExceptionTranslationAutoConfiguration,\
org.springframework.boot.autoconfigure.data.cassandra.CassandraDataAutoConfiguration,\
org.springframework.boot.autoconfigure.data.cassandra.CassandraReactiveDataAutoConfiguration,\
org.springframework.boot.autoconfigure.data.cassandra.CassandraReactiveRepositoriesAutoConfiguration,\
org.springframework.boot.autoconfigure.data.cassandra.CassandraRepositoriesAutoConfiguration,\
org.springframework.boot.autoconfigure.data.couchbase.CouchbaseDataAutoConfiguration,\
org.springframework.boot.autoconfigure.data.couchbase.CouchbaseReactiveDataAutoConfiguration,\
org.springframework.boot.autoconfigure.data.couchbase.CouchbaseReactiveRepositoriesAutoConfiguration,\
org.springframework.boot.autoconfigure.data.couchbase.CouchbaseRepositoriesAutoConfiguration,\
org.springframework.boot.autoconfigure.data.elasticsearch.ElasticsearchAutoConfiguration,\
org.springframework.boot.autoconfigure.data.elasticsearch.ElasticsearchDataAutoConfiguration,\
org.springframework.boot.autoconfigure.data.elasticsearch.ElasticsearchRepositoriesAutoConfiguration,\
org.springframework.boot.autoconfigure.data.jpa.JpaRepositoriesAutoConfiguration,\
org.springframework.boot.autoconfigure.data.ldap.LdapDataAutoConfiguration,\
org.springframework.boot.autoconfigure.data.ldap.LdapRepositoriesAutoConfiguration,\
org.springframework.boot.autoconfigure.data.mongo.MongoDataAutoConfiguration,\
org.springframework.boot.autoconfigure.data.mongo.MongoReactiveDataAutoConfiguration,\
org.springframework.boot.autoconfigure.data.mongo.MongoReactiveRepositoriesAutoConfiguration,\
org.springframework.boot.autoconfigure.data.mongo.MongoRepositoriesAutoConfiguration,\
org.springframework.boot.autoconfigure.data.neo4j.Neo4jDataAutoConfiguration,\
org.springframework.boot.autoconfigure.data.neo4j.Neo4jRepositoriesAutoConfiguration,\
org.springframework.boot.autoconfigure.data.solr.SolrRepositoriesAutoConfiguration,\
org.springframework.boot.autoconfigure.data.redis.RedisAutoConfiguration,\
org.springframework.boot.autoconfigure.data.redis.RedisReactiveAutoConfiguration,\
org.springframework.boot.autoconfigure.data.redis.RedisRepositoriesAutoConfiguration,\
org.springframework.boot.autoconfigure.data.rest.RepositoryRestMvcAutoConfiguration,\
org.springframework.boot.autoconfigure.data.web.SpringDataWebAutoConfiguration,\
org.springframework.boot.autoconfigure.elasticsearch.jest.JestAutoConfiguration,\
org.springframework.boot.autoconfigure.flyway.FlywayAutoConfiguration,\
org.springframework.boot.autoconfigure.freemarker.FreeMarkerAutoConfiguration,\
org.springframework.boot.autoconfigure.gson.GsonAutoConfiguration,\
org.springframework.boot.autoconfigure.h2.H2ConsoleAutoConfiguration,\
org.springframework.boot.autoconfigure.hateoas.HypermediaAutoConfiguration,\
org.springframework.boot.autoconfigure.hazelcast.HazelcastAutoConfiguration,\
org.springframework.boot.autoconfigure.hazelcast.HazelcastJpaDependencyAutoConfiguration,\
org.springframework.boot.autoconfigure.http.HttpMessageConvertersAutoConfiguration,\
org.springframework.boot.autoconfigure.http.codec.CodecsAutoConfiguration,\
org.springframework.boot.autoconfigure.influx.InfluxDbAutoConfiguration,\
org.springframework.boot.autoconfigure.info.ProjectInfoAutoConfiguration,\
org.springframework.boot.autoconfigure.integration.IntegrationAutoConfiguration,\
org.springframework.boot.autoconfigure.jackson.JacksonAutoConfiguration,\
org.springframework.boot.autoconfigure.jdbc.DataSourceAutoConfiguration,\
org.springframework.boot.autoconfigure.jdbc.JdbcTemplateAutoConfiguration,\
org.springframework.boot.autoconfigure.jdbc.JndiDataSourceAutoConfiguration,\
org.springframework.boot.autoconfigure.jdbc.XADataSourceAutoConfiguration,\
org.springframework.boot.autoconfigure.jdbc.DataSourceTransactionManagerAutoConfiguration,\
org.springframework.boot.autoconfigure.jms.JmsAutoConfiguration,\
org.springframework.boot.autoconfigure.jmx.JmxAutoConfiguration,\
org.springframework.boot.autoconfigure.jms.JndiConnectionFactoryAutoConfiguration,\
org.springframework.boot.autoconfigure.jms.activemq.ActiveMQAutoConfiguration,\
org.springframework.boot.autoconfigure.jms.artemis.ArtemisAutoConfiguration,\
org.springframework.boot.autoconfigure.groovy.template.GroovyTemplateAutoConfiguration,\
org.springframework.boot.autoconfigure.jersey.JerseyAutoConfiguration,\
org.springframework.boot.autoconfigure.jooq.JooqAutoConfiguration,\
org.springframework.boot.autoconfigure.jsonb.JsonbAutoConfiguration,\
org.springframework.boot.autoconfigure.kafka.KafkaAutoConfiguration,\
org.springframework.boot.autoconfigure.ldap.embedded.EmbeddedLdapAutoConfiguration,\
org.springframework.boot.autoconfigure.ldap.LdapAutoConfiguration,\
org.springframework.boot.autoconfigure.liquibase.LiquibaseAutoConfiguration,\
org.springframework.boot.autoconfigure.mail.MailSenderAutoConfiguration,\
org.springframework.boot.autoconfigure.mail.MailSenderValidatorAutoConfiguration,\
org.springframework.boot.autoconfigure.mongo.embedded.EmbeddedMongoAutoConfiguration,\
org.springframework.boot.autoconfigure.mongo.MongoAutoConfiguration,\
org.springframework.boot.autoconfigure.mongo.MongoReactiveAutoConfiguration,\
org.springframework.boot.autoconfigure.mustache.MustacheAutoConfiguration,\
org.springframework.boot.autoconfigure.orm.jpa.HibernateJpaAutoConfiguration,\
org.springframework.boot.autoconfigure.quartz.QuartzAutoConfiguration,\
org.springframework.boot.autoconfigure.reactor.core.ReactorCoreAutoConfiguration,\
org.springframework.boot.autoconfigure.security.servlet.SecurityAutoConfiguration,\
org.springframework.boot.autoconfigure.security.servlet.UserDetailsServiceAutoConfiguration,\
org.springframework.boot.autoconfigure.security.servlet.SecurityFilterAutoConfiguration,\
org.springframework.boot.autoconfigure.security.reactive.ReactiveSecurityAutoConfiguration,\
org.springframework.boot.autoconfigure.security.reactive.ReactiveUserDetailsServiceAutoConfiguration,\
org.springframework.boot.autoconfigure.sendgrid.SendGridAutoConfiguration,\
org.springframework.boot.autoconfigure.session.SessionAutoConfiguration,\
org.springframework.boot.autoconfigure.security.oauth2.client.OAuth2ClientAutoConfiguration,\
org.springframework.boot.autoconfigure.solr.SolrAutoConfiguration,\
org.springframework.boot.autoconfigure.thymeleaf.ThymeleafAutoConfiguration,\
org.springframework.boot.autoconfigure.transaction.TransactionAutoConfiguration,\
org.springframework.boot.autoconfigure.transaction.jta.JtaAutoConfiguration,\
org.springframework.boot.autoconfigure.validation.ValidationAutoConfiguration,\
org.springframework.boot.autoconfigure.web.client.RestTemplateAutoConfiguration,\
org.springframework.boot.autoconfigure.web.embedded.EmbeddedWebServerFactoryCustomizerAutoConfiguration,\
org.springframework.boot.autoconfigure.web.reactive.HttpHandlerAutoConfiguration,\
org.springframework.boot.autoconfigure.web.reactive.ReactiveWebServerFactoryAutoConfiguration,\
org.springframework.boot.autoconfigure.web.reactive.WebFluxAutoConfiguration,\
org.springframework.boot.autoconfigure.web.reactive.error.ErrorWebFluxAutoConfiguration,\
org.springframework.boot.autoconfigure.web.reactive.function.client.WebClientAutoConfiguration,\
org.springframework.boot.autoconfigure.web.servlet.DispatcherServletAutoConfiguration,\
org.springframework.boot.autoconfigure.web.servlet.ServletWebServerFactoryAutoConfiguration,\
org.springframework.boot.autoconfigure.web.servlet.error.ErrorMvcAutoConfiguration,\
org.springframework.boot.autoconfigure.web.servlet.HttpEncodingAutoConfiguration,\
org.springframework.boot.autoconfigure.web.servlet.MultipartAutoConfiguration,\
org.springframework.boot.autoconfigure.web.servlet.WebMvcAutoConfiguration,\
org.springframework.boot.autoconfigure.websocket.reactive.WebSocketReactiveAutoConfiguration,\
org.springframework.boot.autoconfigure.websocket.servlet.WebSocketServletAutoConfiguration,\
org.springframework.boot.autoconfigure.websocket.servlet.WebSocketMessagingAutoConfiguration,\
org.springframework.boot.autoconfigure.webservices.WebServicesAutoConfiguration
 ```

每一个这样的xxxAutoConfigutation都是容器中的一个组件，都加入到容器中； 用他们来做自动配置

3）.每一个自动配置类进行自动配置功能

4）.以**HttpEncodingAutoConfiguration**为例解释自动配置原理：

```java
@Configuration  // 表示这是一个配置类，和以前的配置文件一样，也可以给容器中添加组件
@EnableConfigurationProperties(HttpEncodingProperties.class)  // 启用ConfigurationProperties；将配置文件绑定起来，并且放入到Spring容器中.
@ConditionalOnWebApplication(type = ConditionalOnWebApplication.Type.SERVLET) // Spring底层@Conditional注解，根据不同的条件，如果满足指定的条件，整个配置类中的配置才会生效
@ConditionalOnClass(CharacterEncodingFilter.class) // 判断当前项目有没有这个类. CharacterEncodingFilter 是SpringMVC中乱码解决的过滤器.
@ConditionalOnProperty(prefix = "spring.http.encoding", value = "enabled", matchIfMissing = true) // 判断配置文件中是否存在某个配置， spring.http.encoding.enabled； 如果不存在，判断也是成立的. 即使配置文件中不配置enable属性，也是默认生效
public class HttpEncodingAutoConfiguration {
    
    // 已经和Springboot的配置文件映射了
    private final HttpEncodingProperties properties;
	
    // 只有一个有参构造器的情况下， 参数的值就会从容器中拿 ，
	public HttpEncodingAutoConfiguration(HttpEncodingProperties properties) {
		this.properties = properties;
	}

    
    @Bean  // 给容器中添加一个组件 ， 这个组件中的属性，需要从properties文件中获取
	@ConditionalOnMissingBean
	public CharacterEncodingFilter characterEncodingFilter() {
		CharacterEncodingFilter filter = new OrderedCharacterEncodingFilter();
		filter.setEncoding(this.properties.getCharset().name());
		filter.setForceRequestEncoding(this.properties.shouldForce(Type.REQUEST));
		filter.setForceResponseEncoding(this.properties.shouldForce(Type.RESPONSE));
		return filter;
	}
```

根据当前不同的条件判断，决定这个配置类是否生效

5）. 所有在配置文件中能配置的属性都是在xxxProperties类中封装着； 配置文件中能配置什么值，就参照某个功能对应的这个属性类

```java
@ConfigurationProperties(prefix = "spring.http.encoding") // 从配置文件中读取值
public class HttpEncodingProperties {
```



**精髓：**

**1）、SpringBoot启动会加载大量的自动配置类**

**2）、我们看需要的功能有没有SpringBoot默认写好的自动配置类**

**3）、 看自动配置类中到底配置了哪些组件，（只要有我们需要的组件，就不需要配置了。）**

**4）、给容器自动配置添加组件的时候，会从properties类中获取某些属性。我们就可以在配置文件中定义这些属性的值。**

#### 2、细节

1、 @Conditional派生注解

作用： 必须是@Conditional指定的条件成立，才给容器中添加组件，配置配的所有内容才生效。

**自动配置类在一定的条件下才能生效；**

通过Conditional的match方法，  可以通过在配置文件中，配置 debug模式

```properties
debug=true
```

就会在控制台中打印自动匹配报告。



## 三、日志

### 1、 日志框架

异步？ 自动归档？ ...

JDBC -- 数据库驱动， 面向接口编程；

所有日志框架有一个统一的接口层，日志门面（日志的抽象层） ; sl4j

给项目中导入具体的日志实现； 之前的日志框架，都是实现的抽象层；

市面上的日志框架：

| 日志门面（日志抽象层）                | 日志实现              |
| ------------------------------------- | --------------------- |
| ~~JCL(jakarta Commons Logging)~~      |                       |
| SLF4J(Simple Logging Facade for Java) | Log4j , Logback       |
| ~~jBoss-logging~~                     | Log4j2 （apache公司） |

日志门面： SlF4J

日志实现： logback



SpringBoot ： 底层是Spring框架， Spring框架默认使用的是JCL

​	**SpringBoot 选用SLF4j 和 LogBack；**

### 2、SLF4j使用

#### 1、如何在系统中使用SLF4j

在开发的时候，日志记录方法的调用，不应该直接调用日志的实现类，而是调用日志抽象层里面的方法；

给系统里面导入slf4j的jar 和logback的实现jar

```java
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class HelloWorld {
  public static void main(String[] args) {
    Logger logger = LoggerFactory.getLogger(HelloWorld.class);
    logger.info("Hello World");
  }
}
```

![click to enlarge](.\images\concrete-bindings.png)



每一个日志的实现框架都有自己的配置文件， 在使用slf4j 以后，**配置文件还是日志实现框架本身的配置文件；**



#### 2、遗留问题

A 系统 (slf4j + logback)  : 依赖 Spring (commons-logging), Hibernate (jboss-logging), MyBatis

统一日志记录， 即使是别的框架也一起用slf4j进行输出。

![](C:\Users\dongzc15247.HS\Desktop\springboot\images\legacy.png)

如何让系统中所有的日志都统一到slf4j 

1、 将系统中其他日志框架排除；

2、 用中间包来替换原有的日志框架；

3、 我们继续导入slf4j的其他实现；

### 3、SpringBoot日志

```xml
    <dependency>
      <groupId>org.springframework.boot</groupId>
      <artifactId>spring-boot-starter-logging</artifactId>
      <version>2.0.2.RELEASE</version>
      <scope>compile</scope>
    </dependency>
```

SpringBoot底层依赖关系：

![1526452686004](C:\Users\dongzc15247.HS\Desktop\springboot\images\springbootlog.png)

总结：

1）、 SpringBoot底层也是用slf4j + logback方式实现

2）、也导入了转换包

3）、如果我们要引入其他框架？ 一定要把这个框架的默认日志依赖移除。

​	Spring框架用的是Commons-logging ；

SpringBoot能自动适配所有的日志，在引入其他框架的时候，只需要把这个框架依赖的日志框架排除掉；

### 4、日志使用

#### 1、默认配置

SpringBoot配置文件修改

````properties
#指定到包级别的日志
logging.level.com.learn = trace
# logging.path
# 不指定路径就在当前项目下生成springboot.log日志
# 可以指定完整路径
logging.path=springboot.log
#logging.file=  指定文件名的

# 在控制台输出的日志格式
logging.pattern.console=
# 指定文件中输出的日志格式
logging.pattern.file=

````

#### 2、指定配置

classpath下放入每个日志框架的配置文件

| Logging System          | Customization                                                |
| ----------------------- | ------------------------------------------------------------ |
| Logback                 | `logback-spring.xml`, `logback-spring.groovy`, `logback.xml`, or `logback.groovy` |
| Log4j2                  | `log4j2-spring.xml` or `log4j2.xml`                          |
| JDK (Java Util Logging) | `logging.properties`                                         |

 推荐使用logback-{profile}的后缀来使用。

标准的logback.xml在很早的时候就被加载掉了，不可以去扩展，可以使用 - , 或者logging.config 文件

可以使用Spring提供的profile标签。 激活不同profile下的日志不同

```xml
<springProfile name="staging">
	<!-- configuration to be enabled when the "staging" profile is active -->
</springProfile>

<springProfile name="dev, staging">
	<!-- configuration to be enabled when the "dev" or "staging" profiles are active -->
</springProfile>

<springProfile name="!production">
	<!-- configuration to be enabled when the "production" profile is not active -->
</springProfile>

```

### 5、切换日志框架

依据Slf4j官方文档来进行切换。



## 四、Spring Boot 与Web 开发

### 1、 简介

使用SpringBoot：

**1）、创建一个Springboot应用， 选中我们需要的模块；**

**2）、SpringBoot已经默认将这些场景配置好？ autoconfiguration  。只需要在配置文件中，指定少量的配置就可以运行。**

**3）、自己编写业务代码；**

### 2、SpringBoot对于静态资源的映射规则

```java
	@Override
		public void addResourceHandlers(ResourceHandlerRegistry registry) {
			if (!this.resourceProperties.isAddMappings()) {
				logger.debug("Default resource handling disabled");
				return;
			}
			Duration cachePeriod = this.resourceProperties.getCache().getPeriod();
			CacheControl cacheControl = this.resourceProperties.getCache()
					.getCachecontrol().toHttpCacheControl();
			if (!registry.hasMappingForPattern("/webjars/**")) {
				customizeResourceHandlerRegistration(registry
						.addResourceHandler("/webjars/**")
						.addResourceLocations("classpath:/META-INF/resources/webjars/")
						.setCachePeriod(getSeconds(cachePeriod))
						.setCacheControl(cacheControl));
			}
			String staticPathPattern = this.mvcProperties.getStaticPathPattern();
			if (!registry.hasMappingForPattern(staticPathPattern)) {
				customizeResourceHandlerRegistration(
						registry.addResourceHandler(staticPathPattern)
								.addResourceLocations(getResourceLocations(
										this.resourceProperties.getStaticLocations()))
								.setCachePeriod(getSeconds(cachePeriod))
								.setCacheControl(cacheControl));
			}
		}

		@Bean
		public WelcomePageHandlerMapping welcomePageHandlerMapping(
				ApplicationContext applicationContext) {
			return new WelcomePageHandlerMapping(
					new TemplateAvailabilityProviders(applicationContext),
					applicationContext, getWelcomePage(),
					this.mvcProperties.getStaticPathPattern());
		}

		//配置喜欢的图标
		@Configuration
		@ConditionalOnProperty(value = "spring.mvc.favicon.enabled", matchIfMissing = true)
		public static class FaviconConfiguration implements ResourceLoaderAware {

			private final ResourceProperties resourceProperties;

			private ResourceLoader resourceLoader;

			public FaviconConfiguration(ResourceProperties resourceProperties) {
				this.resourceProperties = resourceProperties;
			}

			@Override
			public void setResourceLoader(ResourceLoader resourceLoader) {
				this.resourceLoader = resourceLoader;
			}

			@Bean
			public SimpleUrlHandlerMapping faviconHandlerMapping() {
				SimpleUrlHandlerMapping mapping = new SimpleUrlHandlerMapping();
				mapping.setOrder(Ordered.HIGHEST_PRECEDENCE + 1);
				mapping.setUrlMap(Collections.singletonMap("**/favicon.ico",
						faviconRequestHandler()));
				return mapping;
			}

			@Bean
			public ResourceHttpRequestHandler faviconRequestHandler() {
				ResourceHttpRequestHandler requestHandler = new ResourceHttpRequestHandler();
				requestHandler.setLocations(resolveFaviconLocations());
				return requestHandler;
			}

			private List<Resource> resolveFaviconLocations() {
				String[] staticLocations = getResourceLocations(
						this.resourceProperties.getStaticLocations());
				List<Resource> locations = new ArrayList<>(staticLocations.length + 1);
				Arrays.stream(staticLocations).map(this.resourceLoader::getResource)
						.forEach(locations::add);
				locations.add(new ClassPathResource("/"));
				return Collections.unmodifiableList(locations);
			}

		}
```

1）、所有 /webjars/** , 都去 classpath:/META-INF/resource/webjars

​	webjars： 以jar包的方式引入静态资源；

```xml
<!--引入jquery webjars 访问的时候访问/webjars/路径就可以访问--> 
<dependency>
    <groupId>org.webjars</groupId>
    <artifactId>jquery</artifactId>
    <version>3.3.1-1</version>
</dependency>
```

2）、 "/**" 访问当前项目的任何资源 （静态资源文件夹）

```java

			"classpath:/META-INF/resources/", 
			"classpath:/resources/",
			"classpath:/static/", 
			"classpath:/public/" ,
			"/" : 当前项目根路径
```

3）、欢迎页；  静态资源文件夹下的 index.html 与 /**映射

4）、所有 **/favicon.ico都是在静态资源文件夹下找

### 3、模板引擎

JSP、Velocity、Freemarker、Thymeleaf

SpringBoot推荐的Thymeleaf：

语法更简单，功能更强大：

#### 1、引入Thymeleaf

```xml
	<dependency>
			<groupId>org.springframework.boot</groupId>
			<artifactId>spring-boot-starter-thymeleaf</artifactId>
		</dependency>
```

#### 2、Thymeleaf 使用&语法

```java
@ConfigurationProperties(prefix = "spring.thymeleaf")
public class ThymeleafProperties {

	private static final Charset DEFAULT_ENCODING = StandardCharsets.UTF_8;

	public static final String DEFAULT_PREFIX = "classpath:/templates/";

	public static final String DEFAULT_SUFFIX = ".html";

	/**
	 * Whether to check that the template exists before rendering it.
	 */
	private boolean checkTemplate = true;

	/**
	 * Whether to check that the templates location exists.
	 */
	private boolean checkTemplateLocation = true;

	/**
	 * Prefix that gets prepended to view names when building a URL.
	 */
	private String prefix = DEFAULT_PREFIX;

	/**
	 * Suffix that gets appended to view names when building a URL.
	 */
	private String suffix = DEFAULT_SUFFIX;

	/**
	 * Template mode to be applied to templates. See also Thymeleaf's TemplateMode enum.
	 */
	private String mode = "HTML";


```

1. 导入Thymeleaf的名称空间;

2. 使用thymeleaf语法

   见官方文档

### 4、SpringMVC 自动配置

SpringBoot对于SpringMvc的自动配置：

* 视图解析器（ViewResolver） 根据方法的返回值，得到视图对象（View） ， 视图对象决定如何渲染（转发、重定向等）
  * ContentNegotiatingViewResolver： 组合所有的视图解析器；
  * 如何定制？ 只需要增加自己的视图解析器，就会自动被组合进去；
* 对于静态资源的支持，webjars
* 自动注册了 Converter, GenericConverter, and Formatter beans
  * Converter （转换器） public String hello（User user）； 类型转换使用Converter
  * Formatter （格式化器） 用来格式化日期； 在配置文件中配置；
  * 自己想要扩展格式化器也可以， 只需要把扩展的放到容器中。
* 提供HttpMessageConverters 
  * HttpMessageConverters ： SpringMvc用来转换HTTP请求和相应的； 
  * 是从容器中确定值的。 从容器中获取所有的httpmessageconvert
* 自动注册 `MessageCodesResolver`  ： 定义错误代码生成规则的。
* 注册`ConfigurableWebBindingInitializer` ； 初始化webDataBinder；  请求数据 -> JavaBean

### 5、 如何修改SpringBoot的默认配置

模式：

1）、 SpringBoot在主动配置很多组件的时候，先去判断容器中有没有用户自定义的组件。如果没有才注册默认组件。如果有些组件可以有多个，将用户配置的和默认的配置组合起来。

2）、新增

If you want to keep Spring Boot MVC features and you want to add additional [MVC configuration](https://docs.spring.io/spring/docs/5.0.6.RELEASE/spring-framework-reference/web.html#mvc) (interceptors, formatters, view controllers, and other features), you can add your own `@Configuration` class of type `WebMvcConfigurer` but **without** `@EnableWebMvc`. If you wish to provide custom instances of `RequestMappingHandlerMapping`, `RequestMappingHandlerAdapter`, or `ExceptionHandlerExceptionResolver`, you can declare a `WebMvcRegistrationsAdapter` instance to provide such components.

 

### 6、ResultFul CRUD

#### 1）、 访问默认首页，通过配置controller的方式

#### 2）、国际化

1）、编写国际化配置文件；

2）、使用ResourceBundleMessageSource管理国际化资源文件

3）、在页面使用fmt：message取出国际化的内容



国际化Locale（区域对象信息）对象；

```java
		@Bean
		@ConditionalOnMissingBean
		@ConditionalOnProperty(prefix = "spring.mvc", name = "locale")
		public LocaleResolver localeResolver() {
			if (this.mvcProperties
					.getLocaleResolver() == WebMvcProperties.LocaleResolver.FIXED) {
				return new FixedLocaleResolver(this.mvcProperties.getLocale());
			}
             // 根据请求头来获取
			AcceptHeaderLocaleResolver localeResolver = new AcceptHeaderLocaleResolver();
			localeResolver.setDefaultLocale(this.mvcProperties.getLocale());
			return localeResolver;
		}


    public Locale resolveLocale(HttpServletRequest request) {
        Locale defaultLocale = this.getDefaultLocale();
        if(defaultLocale != null && request.getHeader("Accept-Language") == null) {
            return defaultLocale;
        } else {
            Locale requestLocale = request.getLocale();
            List<Locale> supportedLocales = this.getSupportedLocales();
            if(!supportedLocales.isEmpty() && !supportedLocales.contains(requestLocale)) {
                Locale supportedLocale = this.findSupportedLocale(request, supportedLocales);
                return supportedLocale != null?supportedLocale:(defaultLocale != null?defaultLocale:requestLocale);
            } else {
                return requestLocale;
            }
        }
    }

```

