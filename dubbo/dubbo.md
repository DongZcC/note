# Dubbo 学习笔记

## 服务暴露

* 暴露本地服务
* 暴露远程服务
* 启动netty
* 连接zookeeper
* 到zookeeper注册
* 监听zookeeper

![img](D:\工作文档\note\images\webp)







![img](D:\工作文档\note\images\121321)





![img](D:\工作文档\note\images\12321321)









## 问题：

- 既然你对spi有一定了解,那么dubbo的spi和jdk的spi有区别吗?有的话,究竟有什么区别?
  1. JDK的`spi`要用for循环,然后if判断才能获取到指定的spi对象,dubbo用指定的key就可以获取
  2. JDK的`spi`不支持默认值,dubbo增加了默认值的设计
  3. 增加了对ioc 和 aop 的支持

### dubbo中的IOC



![img](D:\工作文档\note\images\dubboioc)



代码过程：

以实例化一个 Compiler为例子

```java
@SPI("javassist")
public interface Compiler {

    /**
     * Compile java source code.
     *
     * @param code        Java source code
     * @param classLoader classloader
     * @return Compiled class
     */
    Class<?> compile(String code, ClassLoader classLoader);

}

```

1. 调用内部private的构造方法 实例化对象；

![1545358455390](D:\工作文档\note\images\1545358455390.png)

2. 实例化内部的各个静态的字段；  初始化 ObjectFactory ； 这里为  AdaptiveExtensionFactory；

![1545358574461](D:\工作文档\note\images\1545358574461.png)



3. 实例化 ExtensionLoader 后，调用该类的 getAdaptiveExtension； 由于是第一次调用，所以需要新创建

![1545358632218](D:\工作文档\note\images\1545358632218.png)



4. 获取有AdaptiveExtensionClass 的类 ； 这里因为存在AdaptiveCompiler ，所以cachedAdaptiveClass存在 ； 不需要自己用字节码生成技术， 生成一个新的Compiler$Adaptive类；

![1545358879446](D:\工作文档\note\images\1545358879446.png)

5. 调用 injectExtension 函数 ； 把Adaptive 类中的 set 方法赋值 （假如这边有需要赋值的扩展 -- > 外部依赖 就继续调用这个扩展类赋值） --> 这个函数是为了初始化这个类的其他依赖

![1545359161654](D:\工作文档\note\images\1545359161654.png)

6. 返回了 Adaptive类，这个类相当于一个 代理类 ； 调用代理类的方法 ； 在这个代理类中，真正找到一个执行方法；

![1545359624507](D:\工作文档\note\images\1545359624507.png)



