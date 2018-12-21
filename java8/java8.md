# 基础

​	Java8对硬件有影响：平时我们用的CPU是多喝的，但是绝大多数现有的Java程序只能使用其中的一个内核，其他的全部闲置。

​	Java8之前，必须利用线程才可以使用多个内核。  但是并发编程一直是很难的，Java8利用一些新的思路，来达到这个效果

* Stream API ： Java8提供了一个新的API ， 它支持许多处理数据的并行操作，其思路和在使句酷查询语言中的思路类似——用更高级的方式，表达想要的东西，而由（Streams库）来选择最佳低级执行机制。这样就避免了用synchronized编写代码。
* 向方法传递代码的技巧
* 接口中的默认方法

## 流处理

​	流是一系列数据，程序可以从输入流中一个一个读取，然后以同样的方式写入输出流。一个程序的输出流很有可能是另一个程序的输入流。

​	Java8在 java.util.stream中添加了一个 Stream API ； Stream<T>就是一系列 T类型的项目。可以把它看成一个比较花哨的迭代器。可以用很多方法 链接成一个复杂的流水线。类似于Unix系统中的管道

​	其中函数式编程的方法，要求不能共享可变的数据，函数的行为类似一个数学函数，不能修改公共变量，有副作用。

​	Java8提供方法引用：： 语法（即 把这个方法作为值） 



> 什么是谓词？ 前 面 的 代 码 传 递 了 方 法  （ 它 接 受 参 数 Apple 并 返 回 一 个 boolean）给filterApples，后者则希望接受一个Predicate<Apple>参数。谓词 （predicate） 在数学上常常用来代表一个类似函数的东西，它接受一个参数值，并返回true或false。你 在后面会看到， Java 8也会允许你写Function<Apple,Boolean>——在学校学过函数却没学 过谓词的读者对此可能更熟悉，但用Predicate<Apple>是更标准的方式，效率也会更高一 点儿，这避免了把boolean封装在Boolean里面    



​	几乎每一个Java应用都会制造和处理集合。 但是集合用起来并不总是那么理想， 比方说，需要从一个列表中筛选金额较高的交易，然后按照货币分组， 需要写一大段代码来实现这个命令



![1531394027930](D:\工作文档\note\images\1531394027930.png)



但是有了 流API 后，就可以以下代码解决问题：

![1531394056163](D:\工作文档\note\images\1531394056163.png)



​	注意， 和Collection API 相比， Stream API处理数据的方式非常不同， 用集合的话， 需要自己去做迭代的过程， 需要使用for-each 循环去一个个迭代元素，然后处理元素。把这种数据迭代的方式 称为外部迭代。有了Stream API 根本不需要操心循环的事情， 数据处理完全是在库内部进行的 ，这种思想叫做内部迭代。

## 默认方法

​	Java8中加入默认方法，主要是为了支持库设计师，让他们能够写出更容易改进的接口。

```java
List<Apple> heavyApples1 =
	inventory.stream().filter((Apple a) -> a.getWeight() > 150)
	.collect(toList());
List<Apple> heavyApples2 =
	inventory.parallelStream().filter((Apple a) -> a.getWeight() > 150)
	.collect(toList());
```

 	但是在Java8之前 List<T>并没有 stream或者parallelStream方法， 它实现的Collection<T>接口也没有 。 这样设计者就陷入了两难：**如何改变已经发布的接口而不破坏已有的实现呢？**

​	Java8提供 ----接口如今可以包含实现类没有提供实现的方法签名了！ 那谁来实现它呢？ 确实的方法主题岁接口提供了（因此有了默认实现） 而不是由实现类提供。 Java8在接口声明中使用新的 default关键字来表示

## 其他优秀思想

​	Java8中有一个Optional<T>类，如果可以一致的使用它，就可以帮助避免出现NullPointer异常。它是一个容器对象，可以包含，也可以不包含一个值。Optional<T>中有方法来明确处理值不存在的情况。第二个想法是，模式匹配 



# 通过行为参数化传递代码

​	行为参数化就是可以帮助你处理频繁变更的需求的一种软件开发模式。

​	一种更高层次的抽象， 谓词（一个返回boolean值的函数） 有点类似策略模式， 但是可以抽取行为

## Lambda表达式

​	利用参数化来传递代码，有助于应对不断变化的需求。允许定义一个代码块来表示一个行为，然后传递他。可以决定在某一时间发生时，运行该代码块。

​	特点：

* 匿名 ： 不像普通的方法那样有一个明确的名称：写得少而想的多
* 函数： Lambda不像方法那样属于某个特定的类。但和方法一样Lambda有参数列表，函数主体、返回类型，还可能有可以抛出的异常列表
* 传递 ：Lambda表达式可以作为参数主体 传递给方法 或者储存在变量中
* 简洁 ： 无需像匿名类那样写很多模板代码

包含：

* 参数列表 
* 箭头
* Lambda主体
* （parameters） -> expression
* （parameters） -> {statements;}

![1531467978646](D:\工作文档\note\images\1531467978646.png)

## Lambda表达式用在哪些地方



### 函数式接口

​	函数式接口就是只定义一个抽象方法的接口。 Lambda表达式允许直接以内敛的形式为函数式接口的抽象方法提供实现， 并把整个表达式作为函数式接口的实例。

>  接口现在还有默认方法，哪怕有很多默认方法， 只要接口定义了一个抽象方法，  他就仍然是一个函数式接口



### 函数描述符

  函数式接口的抽象方法的签名， 基本上就是Lambda表达式的签名。我们将这种抽象方法叫做函数描述符。

用 ()-> void 代表 参数列表为空，返回为void 的函数 。 Lambda表达式的签名， 要和函数式接口的抽象方法一样。



> @FunctionalInterface 
>
> ​	这个标注用于表示该接口会设计成一个函数式接口。如果用了这个注解，但是却不是函数式接口的话，编译器会返回一个提示原因的错误。 就类似于@Override 标注表示方法被重写了。



## 把Lambda付诸实践：环绕执行模式

![1531470231650](D:\工作文档\note\images\1531470231650.png)





```java
public static String processFile() throws IOException {
    try (BufferedReader br =
    		new BufferedReader(new FileReader("data.txt"))) {
    	return br.readLine();
	}
}
```

### 第一步：记得行为参数化

​	现在上面这段代码是有局限性的，只能读文件的第一行。 如果想要读取两行该如何操作？  

​	这里需要一个 接受 BufferedReader 并 返回 String 的Lambda

### 第二步：使用函数式接口来传递行为

​	新建一个 BufferedReaderProcessor接口， 来作为Lambda传递的载体

```java
@FunctionalInterface
public interface BufferedReaderProcessor {
    String process(BufferedReader bufferedReader) throws IOException;
}
```

### 第三步：执行一个行为

​	任何BufferedReader -> String 形式的Lambda都可以作为参数来传递， 因为他们复合BufferedReaderProcessor接口中定义的process 方法的签名。

```java
    public static String processFile(BufferedReaderProcessor p) throws IOException {
        try (BufferedReader bf = new BufferedReader(new FileReader("data.txt"))) {
            return p.process(bf);
        }
    }
```



### 第四步：传递Lambda

这时就可以编写不同的Lambda重用 processFile方法， 并以不同的方式处理文件了。

```java
        String oneLine = processFile(BufferedReader::readLine);
        String twoLines = processFile((BufferedReader br) -> br.readLine() + br.readLine());
```



![1531471215663](D:\工作文档\note\images\1531471215663.png)

​	这上面已经讨论如何利用函数式接口来传递Lambda ， 但是还需要定义自己的接口。

## 使用函数式接口

​	函数式接口定义且只定义了一个抽象方法。函数式接口很有用，因为抽象方法的签名可以描述Lambda表达式的签名。函数式接口的抽象方法的签名 称为 **函数描述符**。 所以为了应用不同的Lambda表达式， 需要一套能够描述常见函数描述符的函数是接口。

​	Java8的库设计师在 java.util.function包中引入了几个新的函数式接口

### Predicate

​	java.util.function.Predicate<T> 接口定义了一个名叫test的抽象方法，  接受泛型T对象， 并返回一个 boolean 。 现在需要表示一个涉及 T 类型的 布尔表达式时， 就可以直接使用这个接口。

```java
    public static <T> List<T> filter(List<T> list, Predicate<T> p) {
        List<T> results = new ArrayList<>();
        for (T s : list) {
            if (p.test(s)) {
                results.add(s);
            }
        }
        return results;
    }
```

### Consumer

​	java.util.function.Consumer<T> 定义了一个名为 accept的抽象方法，它接受泛型T的对象， 没有返回(void) 。如果需要访问类型T对象， 并对其执行操作，就可以用这个接口。 可以用它来创建一个forEach方法， 并对每个元素执行操作



```java
    public static <T> void forEach(List<T> list, Consumer<T> consumer) {
        for (T t : list) {
            consumer.accept(t);
        }
    }
```



### Function

​	java.util.function.Function<T, R> 接口定义了一个叫做apply的方法。它接受一个泛型T的对象， 并返回一个泛型R的对象。 如果你需要定义一个Lambda 将输入对象的信息映射到输出，就可以使用这个接口

```java
    public static <T, R> List<R> map(List<T> list, Function<T, R> f) {
        List<R> results = new ArrayList<>();
        for (T t : list) {
            results.add(f.apply(t));
        }
        return results;
    }

        List<Integer> l = map(Arrays.asList("lambdas", "in", "action"), String::length);

```

#### 原始类型特化

Java要么就是引用类型（Byte，Integer，Object，List） 要么是原始数据类型（int ， double， byte，char） 但是泛型 T 只能绑定到引用类型。 由于Java中的自动拆装箱机制。 装箱后的类型， 需要消耗更多的内存， 因此提供一些特化，来避免自动拆装箱的操作。

![1531473197726](D:\工作文档\note\images\1531473197726.png)

![1531473214926](C:\Users\DONGZC~1.HS\AppData\Local\Temp\1531473214926.png)



![1531474415038](D:\工作文档\note\images\1531474415038.png)



> 任何函数式接口都不允许抛出 受检异常（checked exception）。如果需要Lambda表达式来抛出异常， 有两张办法。  1. 定义一个自己的函数接口， 并声明受检异常 。 2.把Lambda包在一个 try / catch 块中。

## 类型检查、类型推断以及限制

​	当第一次提到Lambda表达式时，说它可以为函数式接口生成一个实例。然而Lambda表达式本身并不包含它在实现哪个函数式接口的信息。

### 类型检查

​	Lambda的类型是从Lambda的上下文推断出来的（比如，接受它传递的方法参数，或者接受它的值的局部变量）中Lambda表达式需要的类型成为**目标类型** 

![1531533462223](D:\工作文档\note\images\1531533462223.png)



### 同样的Lambda ， 不同的函数式接口

​	有了目标类型的概念，同一个Lambda表达式可以与不同的函数式接口联系起来， 只要他们的方法签名可以兼容。

> **特殊的void兼容规则**
>
> ​	如果一个Lambda的主体是一个语句表达式，它就和一个返回void的函数描述符兼容（当然需要参数列表也兼容）
>
> ​	Predicate<String> p = s->list.add(s);
>
> ​	Comsumer<String> b = s -> list.add(s);



### 类型推断

​	可以进一步简化代码， Java编译器会从上下文（目标类型） 推断出用什么函数式接口来配合 Lambda表达式，这意味着可以推断出适合Lambda的签名， 因为函数描述符可以通过目标类型来得到。

> 当Lambda 仅有一个类型需要推断的参数时， 参数两边的括号也可以省略

### 使用局部变量

​	Lambda表达式也允许使用自由变量（外层作用域中定义的变量） 就像 匿名类一样。被称作 **捕获 Lambda** 

Lambda可以没有限制的捕获（也就是在其中体中引用） 实例变量和静态变量， 但是局部变量必须显示声明为final 或者 事实上为final

![1531534338954](D:\工作文档\note\images\1531534338954.png)

### 方法引用

![1531534475902](D:\工作文档\note\images\1531534475902.png)

#### 如何构建方法引用 

​	方法引用主要有三类

​	（1） 指向静态方法的方法引用（例如Integer.parseInt）

​	（2）指向任意类型实例方法的方法引用（ String.length 方法  写作 String::length)

​	（3）指向现有对象的实例方法的方法引用（假设有一个局部变量expensiveTransaction 用于存放Transaction对象，它支持实例方法getValue  那么就可以写 expensiveTransaction::getValue）

![1531534893119](D:\工作文档\note\images\1531534893119.png)

### 构造函数引用

​	对于一个现有构造函数， 可以利用它的名称和关键字 new 来创建一个它的引用 。 ClassName::new

![1531535302042](D:\工作文档\note\images\1531535302042.png)



## 复合Lambda表达式

可以把多个Lambda复合成一个复杂表达式。

### 比较器复合

  利用库提供的默认方法，  进行对Lambda的复合操作

### 谓词复合

谓词的接口包括三个方法 negate \ and  和 or

### 函数复合

可以把Function接口所代表的Lambda表达式复合起来， Function接口谓词配了 andThen  和Compose 两个默认方法， 它们都会返回一个 Function的实例

​	andthen .  g (f(x))

​	compse f(g(x))



![1531536823658](D:\工作文档\note\images\1531536823658.png)





# 函数式处理

## 流

​	流是Java API的新成员， 允许以声明性方式处理集合数据（通过查询语句来表达，而不是临时编写一个实现）。就现在来说可以看成遍历数据集的高级迭代器。此外 ，流还可以透明的并行处理。

* 代码是以声明式写的： 说明想完成什么 而不是说明如何实现一个操作（利用循环和if等条件控制语句）
* 可以把几个基础操作链接起来，来表达复杂的数据处理流水线

## 流简介

流是什么？ 

* 元素序列 —— 就像集合一样， 流也提供了一个接口，可以访问特定元素类型的一组有序值。因为集合是数据结构，所以它的主要目的是以特定的时间/空间复杂度存储和访问元素（如ArrayList 和LinkedList）。但流的目的在于 **表达计算** 
* 源 —— 流会使用一个提供数据的源 ， 如集合 、数组、 或者输入输出 资源。注意： 从有序集合生成流时会保留原有的顺序， 由列表生成的流， 其元素顺序与列表一致。
* 数据处理操作 —— 流的数据处理功能支持类似数据库的操作，以及函数式编程语言中的常用操作 ， 如 filter 、 map、 reduce、 find、 match、 sort 等
* 流水线—— 很多流操作本身会返回一个流， 这样多个操作就可以链接起来，形成一个大的流水线。  这让一些优化成为可能， 如  **延迟 和 短路**
* 内部迭代 —— 与使用迭代器显示迭代集合不同，流的迭代操作是在背后进行的。



```java
        List<Dish> menu = Arrays.asList(
                new Dish("pork", false, 800, Dish.Type.MEAT),
                new Dish("beef", false, 700, Dish.Type.MEAT),
                new Dish("chicken", false, 400, Dish.Type.MEAT),
                new Dish("french fries", true, 530, Dish.Type.OTHER),
                new Dish("rice", true, 350, Dish.Type.OTHER),
                new Dish("season fruit", true, 120, Dish.Type.OTHER),
                new Dish("pizza", true, 550, Dish.Type.OTHER),
                new Dish("prawns", false, 300, Dish.Type.FISH),
                new Dish("salmon", false, 450, Dish.Type.FISH));


        List<String> threeHighCaloricDishNames =
                menu.stream()
                        .filter(d -> d.getCalories() > 300)
                        .map(Dish::getName)
                        .limit(3)  // 只选择头三个
                        .collect(toList());
```

​	![1531813188316](D:\工作文档\note\images\1531813188316.png)



## 流与集合

​	集合与流之间的差异就在于什么时候进行计算。集合是一个内存中的数据结构，它包含数据结构中目前所有的值——集合中的每个元素必须先算出来才能添加到集合着那个。

​	相比之下，流则是在概念上固定的数据结构（你不能添加或删除元素），其元素则是按需计算的。思想就是从流中提取需要的值，而这些值——在用户看不见的地方——只会按需生成。这是一种生产者-消费者的关系。

​	以质数为例，要是想创建一个包含所有质数的集合，那这个程序算起 来就没完没了了，因为总有新的质数要算，然后把它加到集合里面。当然这个集合是永远也创建 不完的，消费者这辈子都见不着了    

![1531893035468](D:\工作文档\note\images\1531893035468.png)



### 只能遍历一次

​	和迭代器类似， 流只能遍历一次。遍历完之后，这个流就已经被消费掉了。你可以从原始数据中再获得一个流来重新遍历一遍（假设是集合之类的可重复的源 ， 如果是IO通道就没戏）

### 外部迭代与内部迭代

​	使用Collection接口需要用户去做迭代（for-each) ， 这称为外部迭代。相反，Streams库使用内部迭代。

## 流操作

流操作一般的有两类操作

* filter 、 map 和 limit可以连成一条流水线  （中间操作）
* collect 触发流水线执行并关闭它 （终端操作）

### 中间操作

​	诸如filter sorted等中间操作会返回另一个流，这让多个操作连接起来星辰一个查询。重要的是，除了在流水线上触发一个终端操作，否则中间操作不会执行任何处理。

![1531894932751](D:\工作文档\note\images\1531894932751.png)

​	上述代码中， 好几种优化 利用了流的延迟性质。

* 尽管很多菜的热量都高于300卡路里，但是之选出了前三个， 因为limit操作和一种称为短路的技巧。
* 尽管filter和map是两个独立的操作，但他们合并到了同一次遍历中了（循环合并）

### 终端操作

​	终端操作会从流的流水线生成结果。其结果是任何不是流的值，比如 List, Integer， 甚至 void 。

流的使用包括三件事

* 一个数据源来执行一个查询
* 一个中间操作链，形成一条流的流水线
* 一个终端操作，执行流水线并生成结果

流的流水线背后的理念类似于构造器模式。在构造器模式中有一个调用链用来设置一套配置（对流来说就是一个中间操作链） ，接着是调用build方法，（对流来说就是终端操作）



## 使用流

​	学习Stream API 支持的许多操作。 这些操作可以快速完成复杂的数据查询 如 筛选、 切片、映射、查找、匹配和规约。 和一些特殊的流： 数值流， 来自文件和数组等多种来源的流， 最后是无限流。

### 筛选和切片

如何选择流中的元素： 用谓词筛选， 筛选出各不相同的元素， 忽略流中头几个元素，或者将流截短至指定长度。

#### 用谓词筛选

​	Streams接口支持filter方法。 该操作会接受一个谓词（一个返回boolean的函数）作为参数，并返回一个包括所有符合谓词的元素的流。

#### 筛选各异的元素

​	流还支持一个叫做distinct的方法，它会返回一个元素各异（根据流所生成元素的hashcode和equals方法实现）的流。

#### 截短流

​	流支持limit（n） 该方法会返回一个不超过给定长度的流。所需唱的作为参数传递给limit。如果流是有序的，则最多返回前n个元素。

#### 跳过元素

​	流还支持skip(n)  ， 返回一个扔掉了前 n 个元素的流 。 如果流中元素不足 n 个， 则返回一个空流。 

### 映射

​	一个非常常见的数据处理套路，就是从某些对象中选择信息。在SQL里， 可以从表中选择一列。 Stream API也通过map和flatMap提供了类似工具。

#### 对流中每一个元素应用函数

​	流支持map方法， 会接受一个函数作为参数。这个函数会被应用到每个元素上，并将其映射成一个新的元素（创建一个新的版本 ， 而不是去修改）

```java
List<String> dishNames = menu.stream().map(Dish::getName).collect(toList());
```

​	因为getName方法返回一个String ， 所以map方法输出流的类型就是 Stream<String>

#### 流的扁平化

​	给定一个单词列表 【“Hello”， "World"】 想要返回列表 【”H“，”e“，”l“，”o“，”w“，”r“，”d“】去掉重复的字符。 如果直接使用  下面代码的解决方式，是不行的。

```java
words.stream()
.map(word -> word.split(""))
.distinct()
.collect(toList());
```

种种方式，传递给 map 方法的Lambda 为每个单词返回了一个 String【】类型的。 因此 map返回的流 实际上是 Stream<String[]> 类型。 

![1532074662252](D:\工作文档\note\images\1532074662252.png)



可以配合使用 Arrays.stream 和 flatMap 来解决这个问题

```java
List<String> uniqueCharacters =
words.stream()
.map(w -> w.split(""))
.flatMap(Arrays::stream)
.distinct()
.collect(Collectors.toList());
```



使用flatmap的效果是，各个数组并不是分别映射成一个流， 而是映射成流的内容。



![1532075026719](D:\工作文档\note\images\1532075026719.png)



flatMap 就是把一个流中的每个值都 合并成另一个流， 就是把所有的流连接成一个流。

### 查找和匹配

​	常见的数据处理套路是看看数据集中的某些元素是否匹配一个给定的属性， Stream API通过 allMatch 、 anyMatch、 noneMatch、 finderFirst 和 findAny 方法提供了这样的工具。

#### 检查谓词是否至少匹配一个元素

​	anyMatch可以回答“ 流中是否有一个元素能匹配给定谓词” ， 可以用来看菜单是否有素食可选。

#### 查找元素

​	findAny方法返回当前流中的任意元素。它可以与其他流结合使用。

#### 查找第一个元素

​	有些流有一个出现顺序（encounter order）来指定流中项目出现的逻辑顺序（比如由List或者排好序的数据生成的流）， 对于这种流 ， 可能想要找到第一个元素。 为此有一个findFirst方法。工作方式类似findany

### 归约

​	如何把一个流中的元素组合起来，使用reduce操作来表达更复杂的查询。

#### 元素求和

```java
        List<Integer> numbers = Arrays.asList(1, 2, 3, 4, 5, 6, 7);
        int sum = 0;
        for (int x : numbers) {
            sum += x;
        }


        sum = numbers.stream().reduce(0, (a, b) -> a + b);
```

这里展示reduce操作是如何作用于一个流：Lambda反复结合每个元素， 直到流被归约成一个值。



![1532333606437](D:\工作文档\note\images\1532333606437.png)

也可以有一个重载的变体， 不接受初始值 返回一个 Optional对象。



#### 最大值和最小值

reduce接收两个参数

* 一个初始值
* 一个Lambda来把两个流元素结合起来并产生一个新值。

```java
        Optional<Integer> max = numbers.stream().reduce(Integer::max);
```

![1532333761810](D:\工作文档\note\images\1532333761810.png)





```java
        // 5.3 用map 和reduce 数流中总共有多少个菜
        int sumOfDish = menu.stream().map(d -> 1).reduce(0, Integer::sum);
	    // 这种 map 和 reduce连接 通常称为 map reduce模式。
```



#### 流操作总结

![1532334767730](D:\工作文档\note\images\1532334767730.png)



### 实践

```java
    public static void main(String[] args) {
        Trader raoul = new Trader("Raoul", "Cambridge");
        Trader mario = new Trader("Mario", "Milan");
        Trader alan = new Trader("Alan", "Cambridge");
        Trader brian = new Trader("Brian", "Cambridge");
        List<Transaction> transactions = Arrays.asList(
                new Transaction(brian, 2011, 300),
                new Transaction(raoul, 2012, 1000),
                new Transaction(raoul, 2011, 400),
                new Transaction(mario, 2012, 710),
                new Transaction(mario, 2012, 700),
                new Transaction(alan, 2012, 950)
        );

        // (1) 找出2011年发生的所有交易，并按交易额排序（从低到高）。
        List<Transaction> one = transactions
                .stream()
                .filter(t -> t.getYear() == 2011)
                .sorted(Comparator.comparingInt(Transaction::getValue))
                .collect(toList());
        one.forEach(System.out::println);
        // (2) 交易员都在哪些不同的城市工作过？
        List<String> cities = transactions.stream()
                .map(t -> t.getTrader().getCity())
                .distinct()
                .collect(toList());
        System.out.println(cities);
        // (3) 查找所有来自于剑桥的交易员，并按姓名排序。
        List<Trader> traders = transactions
                .stream()
                .map(Transaction::getTrader)
                .filter(t -> "Cambridge".equals(t.getCity()))
                .distinct()
                .sorted(Comparator.comparing(Trader::getName))
                .collect(toList());
        System.out.println(traders);
        // (4) 返回所有交易员的姓名字符串，按字母顺序排序。
        List<String> traderNames = transactions
                .stream()
                .map(Transaction::getTrader)
                .distinct()
                .sorted(Comparator.comparing(Trader::getName))
                .map(Trader::getName)
                .collect(toList());
        System.out.println(traderNames);
        // 有点问题
        String traderStr = transactions.stream().map(t -> t.getTrader().getName()).distinct().sorted().collect(joining());
        // (5) 有没有交易员是在米兰工作的？
        boolean milanTrader = transactions
                .stream()
                .map(Transaction::getTrader)
                .anyMatch(t -> "Milan".equals(t.getCity()));
        System.out.println("is any Trader work in Milan " + milanTrader);
        // (6) 打印生活在剑桥的交易员的所有交易额。
        int valueCount = transactions
                .stream()
                .filter(t -> "Cambridge".equals(t.getTrader().getCity()))
                .map(Transaction::getValue)
                .reduce(0, Integer::sum);
        System.out.println("trade count " + valueCount);
        // (7) 所有交易中，最高的交易额是多少？
        int maxValue = transactions
                .stream()
                .map(Transaction::getValue)
                .reduce(0, Integer::max);
        System.out.println("The max trade value " + maxValue);
        // (8) 找到交易额最小的交易
        int minValue = transactions
                .stream()
                .map(Transaction::getValue)
                .reduce(Integer.MAX_VALUE, Integer::min);
        System.out.println("The min trade value " + minValue);
    }
```



### 数值流

​	Stream API提供了   **原始类型流特化**

#### 原始类型流特化

​	Java8引入了三个原始类型特化流接口来解决 自动拆装箱带来的性能损耗 ： IntStream 、 DoubleStream 和LongStream  ， 分别将流中的元素 特化为 int 、 long、 和 double 。 从而避免了暗含的装箱成本。 每个接口都带来了进行常用数值规约的新方法 ，比如 对数值求和的sum ， 找到最大元素的 max 。 此外还有在必要时再把他们转换回对象流的方法。 这些特化的原因并不在于流的复杂性， 而是装箱造成的复杂性。

* 映射到数值流 常用方法： mapToInt 、 mapToLong 、 mapToDouble
* 转换回对象流  boxed（）
* 默认值OptionalInt ，对于三种原始流特化，也分别有一个Optional 原始类型特化版本： OptionalInt、 OptinalDouble和OptionalLong。  接下来就可以利用 Optional显示处理默认值。

#### 数值范围

和数字打交道时，有一个常用的东西就是数值范围。例如想生成1和100之间的所有数字。Java8提供了用于IntStream 和LongStream的静态方法，生成这种范围， range 和 rangeClosed  。两个方法都是第一个参数接收一个起始值，第二个参数接收结束值。range 是不包含结束值。

#### 数值流应用： 勾股数

```java

        // 生成勾股数组
        Stream<int[]> pythagorean =
                IntStream.rangeClosed(1, 100).boxed()
                        .flatMap(a -> IntStream.rangeClosed(a, 100).filter(b -> Math.sqrt(a * a + b * b) % 1 == 0)
                                .mapToObj(b -> new int[]{a, b, (int) Math.sqrt(a * a + b * b)}));

        pythagorean.limit(5).forEach(t -> System.out.println(t[0] + "," + t[1] + "," + t[2]));


        // 这边计算了两次平方根， 可以优化成只计算一次
        Stream<double[]> py2 =
                IntStream.rangeClosed(1, 100).boxed()
                        .flatMap(a -> IntStream.rangeClosed(a, 100)
                                .mapToObj(b -> new double[]{a, b, Math.sqrt(a * a + b * b)})
                                .filter(t -> t[2] % 1 == 0));
```

### 构建流

除了用stream方法从集合生成流。根据数值范围创建数值流， 还有很多构建流的方法， 从 值序列、 数组、文件来创建流， 甚至由生成函数来创建无限流

#### 由值创建流

可以使用静态方法 Stream.of 通过显示值创建一个流。 它可以接受任意数量的参数。

也可以使用Stream.empty() 创建一个空流

```java
Stream<String> stream = Stream.of("Java8", "Lambdas", "In", "Action")l
Stream<String> emptyStream = Stream.empty();
```

#### 由文件生成流

​	Java中用于处理文件等 I/O操作的 NIO API已更新， 以便利用Stream API  。 java.nio.file.Fiels中很多静态方法都会返回一个流。例如 Files.lines   他会返回一个由指定文件中的各行构成的字符串流。

```java
        // 由文件生成流
        long uniqueWords = 0;
        try (Stream<String> lines = Files.lines(Paths.get("data.txt"), Charset.defaultCharset())) {
            uniqueWords = lines.flatMap(l -> Arrays.stream(l.split(" "))).distinct().count();
        } catch (IOException e) {

        }
```

#### 由函数生成流：创建无限流

 	Stream API 提供了两个静态方法来从函数生成流： Stream.iterate  和 Stream.generate 。 这两个操作可以创建所谓**的无限流：** 不像从固定结合创建的流那样有大小固定的流。 由iterate 和generate 产生的流会用给定的函数 按需创建值，因此可以无穷多的计算下去。 一般使用 limit(n）来对这种流加以限制，避免打印无穷多个值。

##### 1. 迭代

迭代接受一个 UnaryOpearator<T> 作为Lambda  T -> T

```java
        // 迭代
        Stream.iterate(0, n -> n+2)
                .limit(10)
                .forEach(System.out::println);
```

```java
        // 测验5.4：斐波纳契元组序列
        Stream.iterate(new int[]{0, 1}, t -> new int[] {t[1], t[0] + t[1]})
                .limit(20)
                .forEach(t -> System.out.println("(" + t[0] + "," + t[1] + ")"));

```

##### 2.生成

与iterate方法类似， generate方法也可以让你按需生成一个无线流。 但generate不是一次对每个新生成的值应用函数的。它接受一个Supplier<T>   () -> T类型的Lambda提供新的值

```java
        // 生成
        Stream.generate(Math::random)
                .limit(5)
                .forEach(System.out::println);
```

可以创建一个存储状态的供应员，可以修改状态，并在为流生成下一个值时使用. 但是在并行代码中，使用有状态的供应源是不安全的。 使用生成fib数列

```java
        // 一个有状态的生成器，并行下会出问题
        IntSupplier fib = new IntSupplier() {

            private int previous = 0;
            private int current = 1;

            @Override
            public int getAsInt() {
                int oldPrevious = this.previous;
                int nexValue = this.previous + this.current;
                this.previous = this.current;
                this.current = nexValue;
                return oldPrevious;
            }
        };

        IntStream.generate(fib).limit(10).forEach(System.out::println);
```





## 用流收集数据

可以把Java8的流看作花哨又懒惰的数据迭代器。他们支持两种类型的操作： 中间操作（filter 或 map） 和终端操作（count、 findFirst、forEach和reduce）。 中间操作可以链接起来，将一个流转换为另一个流。这些操作不会消耗流， 其目的是建立一个流水线。终端操作会消耗流，以产生一个最终的结果。

收集器可以：

* 对一个交易列表按货币分组，获得该货币的所有交易额综合（返回一个 Map<Currency, Integer>)
* 将交易列表分为两组 ： 贵的和不贵的（返回一个 Map<boolean, List<Transaction>>)
* 创建多级分组，比如按城市对交易分组，然后进一步按照贵或不贵分组（返回一个Map<Boolean, List<Transaction>>)

### 收集器简介

函数式编程相对于指令式编程的一个主要优势： 你只需要指出希望的结果 ——“做什么”  ， 而不用操心执行的步骤—— “如何做“。

#### 收集器用作高级归约

​	收集器非常有用，因为用它可以简洁而灵活的定义collect用来生成结果集合的标准。 对流调用collect方法将对流中的元素 触发一个归约操作（由Collector 来参数化）

![1532434680273](D:\工作文档\note\images\1532434680273.png)



#### 预定义收集器

预定义的收集器主要提供三大功能：

* 将流元素归约和汇总为一个值
* 元素分组
* 元素分区

### 归约和汇总

宽泛点说， 但凡要把六中所有的项目合并成一个结果时 ，就可以用归约操作。 这个结果可以是任何类型， 可以复杂如代表一棵树的多级映射， 或者简单如一个整数。

#### 查找流中的最大值和最小值

如果想找到最大值， 和最小值， 可以使用Collectors.maxBy  和 Collectors.minBy 收集器， 返回一个 Optional对象。

#### 汇总

Collectors类专门为汇总提供了一个工厂方法： Collectors.summingInt 。 可以接受一个把对象映射为求和所需int 的函数， 并返回一个收集器； 该收集器在传递给普通的collect方法后即执行我们所需要的汇总操作。

```java
int totalCalories = menu.stream().collect(summingInt(Dish::getCalories));
```

![1532520073764](D:\工作文档\note\images\Node.js开发指南_中文正版.pdf)



​	汇总不仅仅是求和， 还有 Collectors.averagingInt , 连通对应的Long 和Double可以计算数值的平均数。

​	可以通过summarizingInt 工厂方法返回的收集器。

```java
IntSummaryStatistics menuStistics = menu.stream().collect(summarizingInt(Dish::getCalories))
```

​	这个收集器会把所有的信息收集到一个叫做 IntSummaryStatistics的类中，它 提供了方便的取值（getter）方法来访问结果。打印menuStatisticobject 会得到如下输出 ：

![1532673043312](D:\工作文档\note\images\1532673043312.png)



#### 连接字符串

joining 工厂方法返回的收集器，会把留中每一个对象应用 toString 方法得到的所有字符串连接成一个 字符串。

注意： joining内部使用了StringBuilder来把生成的字符串逐个追加起来的。 



#### 广义的归约汇总

​	讨论到的所有收集器，都是一个可以用reducing工厂方法定义的归约过程的特殊情况。 Collectors.reducing 工厂方法是所有这些特殊情况的一般化。 可以说， 上面的案例知识方便程序员。返回一个 Optional  接受一个 BiFunction<T,T,T>    



### 分组

用Collectors.groupingBy工厂方法返回 的收集器就可以轻松地完成分组任务。



![1532680325282](D:\工作文档\note\images\1532680325282.png)



也可以自定义枚举，进行分类处理

```java
public enum CaloricLevel { DIET, NORMAL, FAT }
	Map<CaloricLevel, List<Dish>> dishesByCaloricLevel = menu.stream().collect(
	groupingBy(dish -> {
	if (dish.getCalories() <= 400) return CaloricLevel.DIET;
	else if (dish.getCalories() <= 700) return
	CaloricLevel.NORMAL;
	else return CaloricLevel.FAT;
} ));
```

#### 多级分组

想要实现多级分组，可以使用一个双参数版本的Collectors.groupingby工厂方法创建的收集器。除了普通的分类函数之外，还可以接受第二个参数。在第二个函数中传入 二级分类函数 ，即可多级分组。

```java
        Map<Dish.Type, Map<CaloricLevel, List<Dish>>> dishesByTypeCaloricLevel =
                menu.stream().collect(
                        groupingBy(Dish::getType,
                                groupingBy(dish -> {
                                    if (dish.getCalories() <= 400) return CaloricLevel.DIET;
                                    else if (dish.getCalories() <= 700) return CaloricLevel.NORMAL;
                                    else return CaloricLevel.FAT;
                                })
                        )
                );
```

#### 按子数组收集数据

传给groupingby的第二个收集器，并不一定要是groupingby 进行多级分组， 也可以是 counting等其他收集器，这样就可以得到别的数据。 

* 把收集器的结果转换为另一种类型， Collectors.collectingAndThen工厂方法返回的收集器 用来包装。



![1532681057521](D:\工作文档\note\images\1532681057521.png)





### 分区

partitioningBy    分区是分组的特殊情况： 由一个为此（返回一个布尔值的函数）作为分类函数， 它称分区函数 。 分区函数返回一个布尔值，意味着得到的分组Map键的类型是Boolean 。于是他最多可以分为两组， true 是一组，  false是一组。

#### 分区的优势

​	分区的好处在于保留了分区函数返回true 或 false 的两套流元素列表。

#### 将数字按质数和非质数分区

​	假设要写一个方法， 接受参数 int n ， 并将前n个自然数分为质数和非质数。

首先需要一个方法， 测试一个数字是否为质数

```java
public boolean isPrime(int candidate) {
    return IntStream.range(2, candate).noneMatch(i -> candidate % i == 0); // 产生一个自然数 范围，从2 开始  如果待测试数字不能被流中任何数字整除 ，则返回true
}
```

![1532952116691](D:\工作文档\note\images\1532952116691.png)

![1532952130854](D:\工作文档\note\images\1532952130854.png)

![1532952159695](D:\工作文档\note\images\1532952159695.png)

### 收集器接口

​	Collector接口包含了一系列方法，为实现具体的归约操作（即收集器）提供了范本。

```java
public interface Collector<T, A, R> {
    Supplier<A> supplier();
    BiConsumer<A, T> accumulator();
    Function<A, R> finisher();
    BinaryOperator<A> combiner();
    Set<Characteristics> characteristics();
}
```

* T 是流中要手机的项目的泛型。
* A 是累加器的类型，累加器是在手机过程中用于积累部分结果的对象
* R 是收集器操作得到的对象（通常但并不一定是集合）的类型

#### 理解Collector接口声明的方法

​	上面接口的五个方法，通过分析注意到前面四个方法都会返回一个会被collect方法调用的函数，而第五个方法characteristics则提供了一系列特征，也就是一个提示列表，告诉collect方法执行归约操作的时候可以应用哪些优化（如并行化）

##### 1.建立新的结果容器： supplier方法

​	supplier方法 必须返回一个结果为空的Supplier，也就是一个无参的函数，在调用时会创建一个空的累加器实例，供数据收集过程使用。很明显，对于将累加器本身作为结果返回的收集器，在对空流执行操作的时候，这个空的累加器也代表了收集过程的结果。

##### 2.将元素添加到结果容器：accumulator

​	accumulator方法会返回执行操作归约的函数。当遍历到流中第n个元素时，这个函数执行时会有两个参数：保存归约结果的累加器（已收集了流中前n-1个项目），还有第n个元素本身。该函数会返回void，因为累加器是原位更新，即函数的执行改变了它的内部状态以体现遍历元素的效果。

##### 3.对结果容器应用最终转换：finisher 方法

​	遍历完流后，finisher方法必须返回在累积过程的最后要调用的一个函数，以便累加器对象转换为整个集合操作的最终结果。

##### 4.合并两个结果容器：combiner方法

​	combiner方法会返回一个供归约操作使用的函数，它定义了对流的各个子部分进行并行处理时，各个子部分归约所得的累加器要如何合并。

​	有了这个方法，就可以对流进行并行归约。 会用到Java7引入的 分支/合并框架和 Spliterator抽象。

* 原始流会以递归方式拆分子流，直到定义流是否需要进一步拆分的一个条件为非
* 所有的子流都可以并行处理
* 最后使用收集器combiner方法返回的函数，将所有部分结果两两合并。

![1533036250886](D:\工作文档\note\images\1533036250886.png)

##### 5.characteristics方法

characteristics方法会返回一个不可变的Characteristics集合，定义了收集器的行为——尤其是流是否可以进行并行归约，以及可以使用哪些优化提示。Characteristics是一个包含三个项目的枚举。

* UNORDERED —— 归约结果不受流中项目的遍历和累积顺序的影响
* CONCURRENT —— accumulator 函数可以从多线程同时调用，且该收集器可以并行归约流。 只会在无序数据源时才可以进行并行归约。
* IDENTITY_FINISH —— 表明完成器方法返回的函数是一个恒等函数，可以跳过。这种情况下，累加器对象将会直接作用归约过程的最终结果。



#### 进行自定义收集不去实现Collector

​	对于IDENTITY_FINISH的收集操作，还有一种方法可以得到同样的结果而无需从头实现新的Collectors接口。Stream有一个重载的collect方法可以接受另外三个函数——supplier 、 accumulator 和combiner 

```java
List<Dish> dishes = menuStream.collect(ArrayList::new, List::add, List:addAll);
```

collect方法不能传递任何Characteristics，所以它永远都是一个IDENTITY_FINISH和 CONCURRENT但并非UNORDERED的收集器    

### 开发自己的收集器以获得更好的性能





## 并行数据处理与性能

​	新的Stream接口可以以声明性方式处理数据集。将外部迭代换为内部迭代，能够让原生Java库控制流元素的处理。

### 并行流

​	可以通过对收集源调用parallelStream 方法来把集合转换为并行流。并行流就是一个把内容分成多个数据块，并用不同的线程分别处理每个数据块的流。这样一来就可以自动把给定操作的工作负荷分配给多核处理器的所有内核。

```java
    public static long sequentialSum(long n) {
        return Stream.iterate(1L, i -> i + 1) // 生成自然数无限流
                .limit(n)
                .reduce(0L, Long::sum); // 对所有数字求和来归纳流
    }


    // 和传统Java代码等价
    public static long iterativeSum(long n) {
        long result = 0;
        for (long i = 1L; i <= n; i++) {
            result += i;
        }
        return result;
    }
```

#### 将顺序流转换为并行流

​	可以把流转换为并行流，从而让上面的归约过程 并行运行 —— 对顺序流调用 parallel方法

#### 测试流性能

​	在使用顺序流、并行流、和传统的Java代码进行百万级数据测试的时候。 流版本的求和更慢， 并行的比顺序流更慢， 实际上这里有两个问题：

- iterate生成的是装箱的对象，必须拆箱成数字才能求和。
- 很难把Iterate分成多个独立块来并行执行。

		这就说明了并行编程可能很复杂，有时候甚至有点违反直觉， 如果用的不对（比如采用了一个不易并行化的操作，如iterate） ， 它甚至让程序的整体性能更差，所以在调用parallel操作时，有必要了解背后的操作。

##### 使用更有针对性的方法

​	可以使用 Long.rangeClosed方法， 这个方法与iterate相比有两个优点

* LongStream.rangeClosed直接产生原始类型的long数字，没有装箱拆箱的开销。    
* LongStream.rangeClosed会生成数字范围，很容易拆分为独立的小块。例如，范围1~20 可分为1~5、 6~10、 11~15和16~20    



#### 正确使用并行流

​	错用并行流而产生错误的首要原因，就是使用算法改变了某些共享状态。

### 高效使用并行流

* 如有疑问，测量 测试一下是否并行可以提高效率
* 留意装箱。 自动装箱和拆箱操作会大大降低性能。 Java8中有原始类型流（IntStream, LongStream, DoubleStream)
* 有些操作本身在并行流上的性能就比顺序流差 。 特别是 limit 和findFirst等依赖元素顺序的操作。
* 还要考虑流的操作流水线的总计算成本。设N是要处理的元素的总数， Q是一个元素通过 流水线的大致处理成本，则N*Q就是这个对成本的一个粗略的定性估计。 Q值较高就意味 着使用并行流时性能好的可能性比较大    
* 对于较小的数据量，选择并行流几乎从来都不是一个好的决定。并行处理少数几个元素 的好处还抵不上并行化造成的额外开销    
* 要考虑流背后的数据结构是否易于分解。例如， ArrayList的拆分效率比LinkedList 高得多，因为前者用不着遍历就可以平均拆分，而后者则必须遍历。另外，用range工厂方法创建的原始类型流也可以快速分解    
* 流自身的特点，以及流水线中的中间操作修改流的方式，都可能会改变分解过程的性能。 例如，一个SIZED流可以分成大小相等的两部分，这样每个部分都可以比较高效地并行处 理，但筛选操作可能丢弃的元素个数却无法预测，导致流本身的大小未知。    
* 还要考虑终端操作中合并步骤的代价是大是小（例如Collector中的combiner方法） 。 如果这一步代价很大，那么组合每个子流产生的部分结果所付出的代价就可能会超出通 过并行流得到的性能提升    

![1533196716723](D:\工作文档\note\images\1533196716723.png)



## 分支/合并框架

​	分支合并框架的目的是以递归方式将可以并行的任务拆分成更小的任务，然后将每个子任务的结果合并起来生成整体的结果。是ExecutorService接口的一个实现，它把子任务分配给线程池（ForkJoinPool)中的工作线程。

###  使用 RecursiveTask     

​	要把任务提交到这个池，必须创建RecursiveTask<R>的一个子类， 其中R是并行化任务（以及所有子任务）产生的结果类型， 或者如果不返回结果， 则是RecursiveAction 类型， 要定义RecursiveTask， 只需要实现唯一的抽象方法 compute  这个方法同时定义了将任务拆分成子任务的逻辑，以及无法再拆分或不方便再拆分时，生成单个子任务结果的逻辑。因此伪代码如下：

```java
if (任务足够小或不可分) {
	顺序计算该任务
} else {
    将任务分成两个子任务
    递归调用本方法， 拆分每个子任务， 等待所有子任务完成
    合并每个子任务结果
}

```

### 使用分支合并框架的最佳做法

​	虽然分支/合并框架还算简单易用，但是也很容易被误用，以下是几个有效使用的最佳做法

* 对一个任务调用join 方法会阻塞调用方，直到该任务做出结果。因此，有必要在两个子任务的计算都开始之后再调用它。
* 不应该在RecursiveTask内部使用ForkJoinPoll的 invoke方法。应该始终直接调用compute或fork方法。只有顺序代码才应该用invoke来启动并行计算。
* 对子任务调用fork方法可以把它安排进ForkJoinPoll。 同时对左边和邮编的子任务调用似乎很自然。 但这样做的效率要比直接对其中一个调用compute低。这样做你可以为其中一个子任务重用同一个线程，从而避免在线程池中多分配一个任务造成的开销。
* 调试使用分支/合并框架的并行计算可能有点棘手。
* 和并行流一样，你不应该理所应当的认为在多喝处理器上使用分支/合并框架就比顺序计算快。所有这些子任务的运行时间都应该比分出新任务所花的时间长；一个惯用方 法是把输入/输出放在一个子任务里，计算放在另一个里，这样计算就可以和输入/输出 同时进行。此外，在比较同一算法的顺序和并行版本的性能时还有别的因素要考虑。就 像任何其他Java代码一样，分支/合并框架需要“预热”或者说要执行几遍才会被JIT编 译器优化。这就是为什么在测量性能之前跑几遍程序很重要，我们的测试框架就是这么 做的。同时还要知道，编译器内置的优化可能会为顺序版本带来一些优势（例如执行死 码分析——删去从未被使用的计算）    



### 工作窃取

怎样才能确定，子任务到多少时，就不需要再分了呢。分支/合并框架工程用一种称为工作窃取（work stealing）的技术来解决这个问题。在实际应用中，这意味着这些任务差不多被平均分配到ForkJoinPool中的所有线程上，每个线程都为分配给它的任务保存一个双向链式队列， 每完成一个任务，就回从队列头上取出下一个任务来执行。基于前面所述的原因，某个线程可能早早的完成了分配给它的任务。也就是它的队列已经空了， 而其他的线程还很忙，这时，这个线程没有闲下来，而是随机选择一个别的线程，从队列的尾巴上偷走一个任务。 这就是为什么任务要划分成许多小任务 而不是少数几个大任务， 这有助于在工作线程之间平衡负载。



![1533212184262](D:\工作文档\note\images\1533212184262.png)





## Spliterator

​	Spliterator是Java8中新加入的接口； 这个名字代表“可分迭代器” （splitable iterator） 和Iterator一样， Splitrator也用于遍历数据源中的元素， 但他是为了并行执行而设计。虽然在实践中可能用不着自己开发Spliterator， 但了解一下它的实现方式会让你对并行流的工作原理有更深入的了解。Java8已经为集合框架中的所有数据结构，提供了一个默认的Spliterator的实现。



```java
public interface Spliterator<T> {
    boolean tryAdvance(Consumer<? super T> action);
    Spliterator<T> trySplit();
    long estimateSize();
    int characteristics();
}
```

​	与往常一样， T是Spliterator遍历的元素的类型。 tryAdvance方法的行为类似于普通的 Iterator，因为它会按顺序一个一个使用Spliterator中的元素，并且如果还有其他元素要遍 历就返回true。但trySplit是专为Spliterator接口设计的，因为它可以把一些元素划出去分 给第二个Spliterator（由该方法返回），让它们两个并行处理。 Spliterator还可通过 estimateSize方法估计还剩下多少元素要遍历，因为即使不那么确切，能快速算出来是一个值 也有助于让拆分均匀一点。    

### 拆分过程

![1533283748838](D:\工作文档\note\images\1533283748838.png)



这个拆分过程也受Spliterator本身的特性影响，而特性是通过characteristics方法声 明的    

#### Spliterator特性

![1533622080534](D:\工作文档\note\images\1533622080534.png)



* 内部迭代让你可以并行处理一个流，而无需在代码中显式使用和协调不同的线程。  
* 虽然并行处理一个流很容易，却不能保证程序在所有情况下都运行得更快。并行软件的 行为和性能有时是违反直觉的，因此一定要测量，确保你并没有把程序拖得更慢。
* 像并行流那样对一个数据集并行执行操作可以提升性能，特别是要处理的元素数量庞大， 或处理单个元素特别耗时的时候。
* 从性能角度来看，使用正确的数据结构，如尽可能利用原始流而不是一般化的流，几乎 总是比尝试并行化某些操作更为重要。 
* 分支/合并框架让你得以用递归方式将可以并行的任务拆分成更小的任务，在不同的线程 上执行，然后将各个子任务的结果合并起来生成整体结果。
* Spliterator定义了并行流如何拆分它要遍历的数据    





# 高效 Java 8 编程     



##   重构、测试和调试

### 为改善可读性和灵活性重构代码

#### 增加代码的灵活性

* 采用函数接口 ： 没有函数接口就无法使用Lambda 表达式。因此需要在代码中引入函数式接口。在以下两种通用模式下，可以重构代码： 1. 有条件的延迟  2. 环绕执行

* 有条件的延迟执行：

  ```java
  // 这种方式很垃圾
  if (logger.isLoggable(Log.FIER)) {
      logger.finer("...");
  }
  
  // 这种很
  logger.log(Level.FINER, "...");
  ```

  

![1533641346857](D:\工作文档\note\images\1533641346857.png)

​	如果需要频繁的从客户端代码中查询一个对象的状态，只是为了传递参数，调用该对象的一个方法， 那么可以考虑实现一个新的方法，以Lambda表达式作为参数。

* 环绕执行 ： 虽然业务代码差别很大，但是拥有同样的准备和清理阶段。这时可以用Lambda表达式实现

![1533641844773](D:\工作文档\note\images\1533641844773.png)





### 使用Lambda重构面向对象的设计模式

#### 策略模式

​	策略模式代表了解决一类算法的通用解决方案，可以在运行时选择使用哪种方案。

​	Lambda表达式提供的一些方法 （Predict） 和策略模式拥有相同的签名。

#### 模板方法

​	如果需要采用某个算法的框架， 同时又希望有一定的灵活度，能对它的某些部分进行改进。

```java
// 例如代码
public void processCustomer(int id) {
    Customer c = Database.get；
        makecustomerHappy(c);
}

abstract void makecustomerHappy(Customer c);
```

这个时候就可以用cunsumer ， 类型参数与参数类型一致。





#### 观察者模式





#### 责任链模式

​	责任链模式是一种创建处理对象序列（比如操作序列）的通用方案    

UnaryOperator     和 andThen 运用起来，构成一个 操作链式结构。



#### 工厂模式

```java
public class ProductFactory {
public static Product createProduct(String name){
    switch(name){
        case "loan": return new Loan();
        case "stock": return new Stock();
        case "bond": return new Bond();
        default: throw new RuntimeException("No such product " + name);
    }
}
}


//可以变更为
final static Map<String, Supplier<Product>> map = new HashMap<>();
static {
    map.put("loan", Loan::new);
    map.put("stock", Stock::new);
    map.put("bond", Bond::new);
}


public static Product createProduct(String name){
    Supplier<Product> p = map.get(name);
    if(p != null) return p.get();
    	throw new IllegalArgumentException("No such product " + name);
}

// 但是如果工厂方法需要接受多个参数， 就回比较麻烦， 扩展性不是很好
```



## 默认方法

​	Java8允许在接口内申请静态方法。 引入默认方法， 通过默认方法指定接口方法的默认实现。

在默认方法前， 返回default 关键字

```java
default void sort(Comparator<? super E> C) {
    Collections.sort(this, c);
}
```



![1533711941957](D:\工作文档\note\images\1533711941957.png)



默认方法为方法的多继承提供了一种更灵活的机制，可以帮助你更好地规划你的代 码结构：类可以从多个接口继承默认方法。因此，即使你并非类库的设计者，也能在其中发现 感兴趣的东西    

可以通过创建默认方法的方式 ，构造Java语言的多继承。



### 不断演进的API



> 不同类型的兼容性： 二进制、源代码和函数行为 
>
> ​	变更对Java程序的影响大体可以分成三种类型的兼容性，分别是：二进制级的兼容、源代 码级的兼容，以及函数行为的兼容。 ①刚才我们看到，向接口添加新方法是二进制级的兼容， 但最终编译实现接口的类时却会发生编译错误。了解不同类型兼容性的特性是非常有益的，下 面我们会深入介绍这部分的内容。
>
> ​	 二进制级的兼容性表示现有的二进制执行文件能无缝持续链接（包括验证、准备和解析） 和运行。比如，为接口添加一个方法就是二进制级的兼容，这种方式下，如果新添加的方法不 被调用，接口已经实现的方法可以继续运行，不会出现错误。
>
> ​	 简单地说，源代码级的兼容性表示引入变化之后，现有的程序依然能成功编译通过。比如， 向接口添加新的方法就不是源码级的兼容，因为遗留代码并没有实现新引入的方法，所以它们 无法顺利通过编译。
>
> ​	 最后，函数行为的兼容性表示变更发生之后，程序接受同样的输入能得到同样的结果。比 如，为接口添加新的方法就是函数行为兼容的，因为新添加的方法在程序中并未被调用（抑或 该接口在实现中被覆盖了）    





> Java8 中的抽象类和抽象接口
>
> ​	一个类只能继承一个抽象类， 但是一个类可以实现多个接口
>
> ​	一个抽象类可以通过实例变量  保存一个通用状态， 而接口是不能有实例变量的。





### 默认方法的使用模式

#### 可选方法

​	可能存在这种情况， 类为了实现接口，不过可以的将一些方法的实现留白。

​	通过用 default 方式，为这种接口提供默认实现。 可以减少无用的模板代码。

#### 行为的多继承

![1533715310907](D:\工作文档\note\images\1533715310907.png)

````java
public class ArrayList<E> extends AbstractList<E>
implements List<E>, RandomAccess, Cloneable,
Serializable, Iterable<E>, Collection<E>
````

##### 1.类型的多继承

​	ArrayList继承了一个类，实现了6个接口， 因此ArrayList是 7 个类型的直接子类。

##### 2.利用正交方法的精简接口

##### 3. 组合接口



> 关于继承的一些错误观点
>
>  	继承不应该成为你一谈到代码复用就试图倚靠的万精油。比如，从一个拥有100个方法及 字段的类进行继承就不是个好主意，因为这其实会引入不必要的复杂性。你完全可以使用代理 有效地规避这种窘境，即创建一个方法通过该类的成员变量直接调用该类的方法。这就是为什 么有的时候我们发现有些类被刻意地声明为final类型：声明为final的类不能被其他的类继 承，避免发生这样的反模式，防止核心代码的功能被污染。注意，有的时候声明为final的类 都会有其不同的原因，比如， String类被声明为final，因为我们不希望有人对这样的核心 功能产生干扰。 
>
> ​	这种思想同样也适用于使用默认方法的接口。通过精简的接口，你能获得最有效的组合， 因为你可以只选择你需要的实现    



### 解决冲突的规则

#### 解决问题的三条规则

​	如果一个类使用相同的函数签名从多个地方（比如另一个类或接口）继承了方法，通过三条规则可以进行判断。

1.类中的方法优先级最高。 类或父类中申明的方法优先级高于任何声明为默认方法的优先级。

2.如果无法依据第一条进行判断，那么子接口优先级更高：函数签名相同时，优先选择拥有最具体实现的默认方法接口。 如果B 继承 接口A ， 那么 B 就比 A 更加具体。

3.如果还是无法判断， 继承多个接口的类，必须显示覆盖和调用期望。



#### 菱形继承问题

```java
public interface A {
    default void hello() {
        System.out.println("Hello from A");
    }
}

public interface B extends A {}

public interface C extends A {}

public class D implements B,C {
    public static void main(String ...args) {
        new D().hello();
    }
}

/*

如果一个类的默认方法使用相同的函数签名继承自多个接口，解决
冲突的机制其实相当简单。你只需要遵守下面这三条准则就能解决所有可能的冲突。
 首先，类或父类中显式声明的方法，其优先级高于所有的默认方法。
 如果用第一条无法判断，方法签名又没有区别，那么选择提供最具体实现的默认方法的
接口。
 最后，如果冲突依旧无法解决，你就只能在你的类中覆盖该默认方法，显式地指定在你
的类中使用哪一个接口中的方法
*/
```



## 用Optional取代null

### 如何为缺失的值建模

...

### Optional类入门

​	Java8引入了一个新的类 java.util.Optional<T> 。这是一个封装Optional值的类。 如果你知道一个人有可能有， 也有可能没有车， 那么Person类内部的car 变量就不应该申明为 Car，  遭遇某人没有车时，就把 null 引用赋值给它。 而是应该： 在变量存在时， Optional 知识对类简单封装， 变量不存在时， 缺失的值会被建模成一个空的Optinal对象， 由方法Optional.empty()返回。

![1533718613741](D:\工作文档\note\images\1533718613741.png)

#### 创建Optional对象

1. 声明一个空的Optional  Optional<Car> optCar = Optional.empty();
2. 依据一个非空值创建 Optional<Car> optCar = Optional.of(car);  如果car为空， 则立刻抛出空指针异常
3. 可接受null的Optional  Optional<Car> optCar = Optional.ofNullable(car);



#### 使用map从 Optional对象中提取和转换值

从对象中提取值是一种比较常见的模式。

```java
Optional<Insurance> optInsurance = Optional.ofNullable(insurance);
Optional<String> name = optInsurance.map(Insurance::getName);
```

![1533719998388](D:\工作文档\note\images\1533719998388.png)



#### 使用flatMap链接Optional对接

![1533720722938](D:\工作文档\note\images\1533720722938.png)

#### 默认行为及解引用Optional对象

* get（） 是最简单但又最不安全的方法。 如果变量存在，直接返回封装的变量值， 否则就抛出一个NosuchElementException
* orElse（T other） 允许在Optional不包含值的时候提供一个默认值
* orElseGet(Supplier<? extend T> other) 是orElse的延迟调用版， Supplier方法只有在Optional对象不包含值的时候执行调用。 如果创建默认值是件耗时操作， 应该采用这种操作来提高程序性能。
* orElseThrow（Supplier<T extends X> exceptionSupplier) 和get方法非常类似，遭遇Optional为空时会抛出一个异常，但是使用orElseThrow可以定制希望抛出的异常类型。
* ifPresent（Consumer<? super T>) 让你能在变量值存在时， 执行一个座位参数传入的方法， 否则不进行任何操作。

Optional类和Stream 接口相似之处 有 map flatMap , filte 等方法。

#### 两个Optional对象的组合





#### 使用Optional的实战示例

##### 用Optional封装可能为null的值

​	可以使用Optional.OfNullable() 方法来包装

##### 异常与Optional的对比

可以封装一个工具类， 在抛出异常的时候，处理，转换为一个Optional对象。



## CompletableFuture：组合式异步编程

![1534322806959](D:\工作文档\note\images\1534322806959.png)



### Future 接口

Future接口在Java5中被引入，设计初衷是对将来某个时刻会发生的结果进行建模。**建模了一种异步计算，返回一个执行运算结果的引用。**

​	原本Future接口的局限性，不足以描述以下任务：

* 将两个异步计算合并为一个——这两个异步计算之间相互独立，同时第二个又依赖于第 一个的结果    
* 等待Future集合中的所有任务都完成    
* 仅等待Future集合中最快结束的任务完成（有可能因为它们试图通过不同的方式计算同 一个值），并返回它的结果    
* 通过编程方式完成一个Future任务的执行（即以手工设定异步操作结果的方式    ）
* 应对Future的完成事件（即当Future的完成事件发生时会收到通知，并能使用Future 计算的结果进行下一步的操作，不只是简单地阻塞等待操作的结果）    

上述的这些描述， 需要Java8提供的更有效的API CompleteableFuture 接口来提供。



> 同步API与异步API
>
> ​	 同步API其实只是对传统方法调用的另一种称呼：你调用了某个方法，调用方在被调用方 运行的过程中会等待，被调用方运行结束返回，调用方取得被调用方的返回值并继续运行。即 使调用方和被调用方在不同的线程中运行，调用方还是需要等待被调用方结束运行，这就是阻 塞式调用这个名词的由来。 
>
> ​	与此相反， 异步API会直接返回，或者至少在被调用方计算完成之前，将它剩余的计算任 务交给另一个线程去做，该线程和调用方是异步的——这就是非阻塞式调用的由来。执行剩余 计算任务的线程会将它的计算结果返回给调用方。返回的方式要么是通过回调函数，要么是由 调用方再次执行一个“等待，直到计算完成”的方法调用。这种方式的计算在I/O系统程序设 计中非常常见：你发起了一次磁盘访问，这次访问和你的其他计算操作是异步的，你完成其他 的任务时，磁盘块的数据可能还没载入到内存，你只需要等待数据的载入完成    



![1534334274243](D:\工作文档\note\images\1534334274243.png)

![1534334623115](D:\工作文档\note\images\1534334623115.png)



* 如果是计算密集型， 没有IO 等时间等待的计算， 这个时候推荐用 并行。
* 如果并行的工作单元还涉及等待等IO操作（网络连接等待） 使用异步执行灵活性更好。



### 对于多个异步任务进行流水线操作

![1534399015811](D:\工作文档\note\images\1534399015811.png)







## 日期和时间API