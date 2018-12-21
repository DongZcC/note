### 基础概念

#### 服务组件化：

	组件，是一个可以独立更换和升级的单元。独立且可以更换升级不影响其他单元。

#### SpringCloud简介：

​	Spring Cloud 是一个基于Spring boot 实现的微服务架构开发工具。它为微服务架构中涉及的配置管理、服务治理、断路器、智能路由、微代理、控制总线、全局锁、决策竞选、分布式会话和集群状态等操作提供了简单的开发方式。

	Spring Cloud 包含多个子项目

* Spring Cloud Config ： 配置管理工具，支持使用Git存储配置内容，可以使用它实现应用配置的外部存储话，兵支持客户端配置信息刷新等内容
* Spring Cloud Netflix： 核心组件
  * Eureka： 服务治理组件，包含服务注册中心、服务注册、发现机制
  * Hystrix：容错管理组件，实现断路器模式，帮助服务以来中出现的延迟和故障提供强大的容错能力
  * Ribbon：客户端负载均衡的服务调用组件
  * Feign：基于Ribbon和Hystrix的声明式服务调用组件
  * Zuul：网关组件，提供智能路由、访问过滤等功能
  * Archaius：外部化配置组件
* Spring Cloud Bus： 事件，消息总线，用于传播集群中的状态变化或事件，以触发后续的处理，比如用来动态刷新配置
* Spring Cloud Cluster：针对Zookeeper、Redis、Hazelcast、Consul的选举算法和通用的状态模式实现。
* Spring Cloud Cloudfoundry：与Pivotal CloudFoundry的整合支持。
* Spring Cloud Consul: 服务发现与配置管理工具
* Spring Cloud Stream ： 通过Redis、Rabbit、或者kafka实现的消费微服务，可以通过简单的声明式模型来发送和接收消息
* Spring Cloud AWS： 用于简化整合Amazon Web Service 组件
* Spring Cloud Security： 安全工具包，提供在Zuul代理中对OAuth2客户端请求的中继器
* Spring Cloud Sleuth：Spirng Cloud应用的分布式跟踪实现，可以完美整合 Zipkin
* Spring Cloud Zookeeper： 基于Zookeeper的服务发现与配置管理组件
* Spring Cloud Starters： Spring Cloud 基础组件， 它是基于Spring Boot 风格项目的基础依赖模块
* Spring Cloud CLI：用于在Groovy中快速创建Spring Cloud 应用的Spring Boot CLI插件



### eureka：

​	在Eureka的服务治理体系中，主要分为服务端和客户端两个不同的角色，服务端为服务注册中心，而客户端为各个提供接口的微服务应用。 

​	Eureka客户端的配置主要分为两个方面：

* 服务注册相关配置信息，包括服务注册中心的地址、服务获取的时间间隔、可用区域
* 服务实例的相关配置信息，包括服务实例的名称、ip地址、端口号、健康检查路径等。

