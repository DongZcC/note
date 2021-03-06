# 一、架构

> MySql最重要、最与众不同的特性是他的存储引擎架构，架构设计将查询处理（Query Processing）以及其他任务（Server Task）和数据的存储/提取相分离。这种处理和存储相分离的设计，可以在使用时，根据性能、特性，以及其他需求来选择数据存储的方式。

## 1.1 MySql 逻辑架构

![1528706673743](C:\Users\dongzc15247.HS\Desktop\note\mysql\images\1.png)

第二层架构，是MySql中比较有特色的部分。

MySql大部分核心服务功能都在这一层，包括（查询解析、分析、优化、缓存以及所有内置函数（日期、时间、数学、加密函数））所有跨存储引擎的功能都在这一层实现：存储过程、触发器、视图等；

第三层包含了存储引擎。 存储引擎负责MySql中数据的存储和提取。每个引擎都有自己的优势劣势，**服务器**通过API与存储引擎进行通信。接口屏蔽了不同存储引擎之间的差异，使得差异对上层查询过程透明。

> 存储引擎不会去解析SQL，不同存储引擎之间也不会相互通信。而是简单的相应上层服务器请求。

### 优化与执行

MySql会解析查询，并创建内部数据结构（解析树），然后对其进行各种优化，包括重写查询、决定表的读取顺序，以及选择合适的索引等。用户可以通过（hint）关键字提示优化器，影响他的决策过程。也可以请求优化器解释（explain）优化过程的各个因素，是用户知道服务器是如何进行优化决策的，并提供一个参考基准，便于用户重构查询和schema、修改相关配置。

对于SELECT 语句， 在解析查询之前，服务器会先检查查询缓存（Query Cache），如果能找到对应的查询，服务器不比在执行查询解析、优化和执行的整个过程。

## 1.2 并发控制

MySql在两个层面进行并发控制 ： 服务器层 、 存储引擎层。

### 读写锁

* 共享锁（Shared Lock）  / 读锁 （read Lock)
* 排它锁（exclusive lock） / 写锁（write lock)

### 锁粒度

因为加锁会增加系统的开销，如果系统话费大量的时间来管理锁，而不是存取数据，那么系统的性能会受到影响。

所谓锁策略，就是在锁的开销和数据安全性之间寻求平衡，这种平衡当然也会影响到性能。（大多数商业数据库 系统并没有提供更多的选择，一般都是在表上施加行级锁（row-level lock））

MySql提供了多种选择，每种MySql存储引擎都可以实现自己的锁策略和锁粒度。

在存储引擎的设计中，锁管理是一个非常重要的决定，将所粒度固定在某个级别，可以为某些特定的应用场景提供更好的性能，但是同时却会失去对一些应用场景的良好支持。

#### 表锁（table lock）

表锁是MySql最基本的锁策略，并且是开销最小的策略。

尽管服务引擎可以管理自己的锁，MySQL本身还是会使用各种有效的表锁来实现不同的目的 例如：ALTER TABLE之类的一句，使用表锁，忽略存储引擎的锁机制

#### 行级锁（row lock）

行级锁可以最大程度的支持并发处理（同时也带来了最大的锁开销）。行级锁只在存储引擎实现，MySQL服务器层没有实现。

## 1.3 事务

一组原子性的SQL查询，或者说一个独立的工作单元。如果数据库引擎能够成功的对数据库应用该组查询的全部语句，那么就执行该组查询，如果有一条语句因为崩溃或其他原因无法执行，所有语句都不会执行。

> 银行例子：银行数据库中两张表 支票表和储蓄表 。现在用户 A 的支票账户转200元到他的储蓄账户，那么需要三个步骤
>
> 1.检查支票账户的余额高于200
>
> 2.从支票账户余额中减去200
>
> 3.在储蓄账户余额中增加200

上述三个步骤必须打包在一个事务中。

可以使用START TRANSACTION； 语句开始一个事务， 然后用COMMIT提交事务将修改数据持久保留， 要么使用ROLLBACK撤销所有修改，

```sql
START TRANSACTION;
SELECT balance FROM checking WHERE customer_id = 101;
...
COMMIT;
```

ACID表示原子性（atomicity）、 一致性（consistency）、隔离性（isolation）和持久性（durability）。一个运行良好的事务处理系统，必须具备这些标准特征。

**原子性（atomicity）：**

​	一个事务必须被视为不可分割的最小工作单元，整个事务中的所有操作要么全部提交成功，要么全部回滚失败，对于一个事务来说，不可能执行一部分操作。

**一致性（consistency）：**

​	数据库总是从一个一致的状态转换到另外一个一致的状态。

**隔离性（isolation）：**

​	通常来说，一个事务所做的修改在最终提交之前，对其他事务是不可见的。

**持久性（durability）：**

​	一旦事务提交，则其所做的修改就会永久保存到数据库中。此时即使事务崩溃，修改的数据也不会丢失。

事务处理中额外的安全性也需要额外的开销**，一个实现了ACID的数据库，通常需要更强的CPU处理能力。**

用户可以根据业务是否需要用事务处理，来选择合适的存储引擎。对于一些不需要事务的查询类应用，选择一个非事务的存储引擎，以获得更高的性能。即使存储引擎不支持事务，也可以通过LOCK TABLES 语句为应用提供一定程度的保护，这些都可以用户自主决定。

### 隔离级别

在SQL标准中定义了四种隔离级别，每一种级别都规定了一个事务中所做的修改，哪些在事务内核事务间是可见的，哪些是不可见的。较低级别的隔离通常可以执行更高的并发，系统开销也更低。

* **READ UNCOMMITED（未提交读）** ： 在未提交读级别，事务中的修改，即使没有提交，对其他事务也都是可见的，事务可以读取未提交的数据，这也被称为脏读（Dirty Read）。这个级别会导致很多问题，从性能来说也没有提高很多，但是缺乏其他级别的很多好处，实际应用很少使用。
* **READ COMMITED（提交读）**：大多数数据库系统的默认级别都是READ COMMITTED（MySQL不是）。READ COMMITTED 满足前面提到隔离性的简单定义： 一个事务开始时，只能看见已经提交的事务所做的修改。这个级别也叫做不可重复读（nonrepeatable read） 因为两次执行相同的查询，可能会得到不一样的结果。（虚读）
* **REPEATABLE READ（可重复读）**：REPEATABLE READ 解决了脏读的问题。该级别保证了同一个事务中，多次读取同样的记录，结果是一致的。但是理论上，可重复读隔离级别还是无法解决另一个 幻读的问题（Phantom Read）。幻读：指当某个事物在读取某个范围内记录时，另外一个事务又在该范围内插入了新的记录，当之前的事务再次读取某个范围记录时， 会产生 幻行（Phantom Row）。 InnoDB 和XtraDB存储引擎通过多版本并发控制（MVCC, Multiversion Concurrency Control) 解决了幻读的问题。 可重复读是MySQL默认事务隔离级别。**（指事务不是独立执行时发生的一种现象, 例如：一个事务对表中的数据进行了修改，涉及表中全部行数。 同时 第二个事务也修改表中的数据，这种修改是向表中插入一行新数据，。那么发生操作的第一个用户，会发现表中还有没有修改的数据航，就好像发生了幻觉）**
* **SERIALIZABLE （可串行化）**：是最高的隔离级别，会强制事务串行执行。避免了前面的幻读问题。

![1528721977661](C:\Users\dongzc15247.HS\Desktop\note\mysql\images\2.png)

### 死锁

两个事物（泛指）都占用了一个资源，请求另一个资源，就会导致死锁。

事务一：

```sql
START TRANSACTION;
UPDATE StockPrice SET close = 45.50 WHERE stock_id = 4 and date = '2002-05-01';
UPDATE StockPrice SET close = 19.80 WHERE stock_id = 3 and date = '2002-05-02';
COMMIT;
```

事务二：

```
START TRANSACTION;
UPDATE StockPrice SET high = 20.12 WHERE stock_id = 3 and date = '2002-05-02';
UPDATE StockPrice SET high = 47.20 WHERE stock_id = 4 and date = '2002-05-01';
COMMIT;
```

两个事务同时锁定一行，请求另外一行。 就会发生死锁。

为了解决这种问题，数据库系统实现了各种四所检测和死锁超时机制。越复杂的系统，**比如InnoDB存储引擎，越能检测到死锁的循环依赖，并立即返回一个错误**。还有另外一种解决方式，**就是当查询时间达到锁等待超时的时间设定后放弃锁请求**，这种方式通常来说不太好。InnoDB目前处理死锁的方法是，**将持有最小行级排它锁的事务进行回滚。**

> 锁的行为和顺序是和存储引擎相关的。以同样的顺序执行语句，有些存储引擎会产生死锁，有些则不会。

### 事务日志

事务日志可以帮助提高事务效率。存储引擎在修改表数据时，只需要修改其内存拷贝，再把修改行为记录持久在硬盘的事务日志中，而不用每次都将修改的数据本身持久到磁盘。事务日志持久以后，内存中被修改的数据，可以在后台慢慢刷回到磁盘。**这种方式称之为 预写式日志（Write-Ahead Logging） 修改数据需要写两次磁盘**

### MySQL中的事务

MySQL提供了两种事务型的存储引擎：InnoDB和NDB Cluster。另外还有第三方的存储引擎也支持事务。（XtraDB 和 PBXT）

#### 自动提交（AUTOCOMMIT）

MySQL默认采用自动提交模式。也就是说，如果不是显示开始一个事务，则每个查询都被当做一个事务执行提交操作。在当前连接中，可以通过设置AUTOCOMMIT变量来启用或禁用自动提交模式；

![1528784684117](C:\Users\DONGZC~1.HS\AppData\Local\Temp\1528784684117.png)

AUTOCOMMIT= 0 时 ，所有查询都是在一个事务中。直到显示的COMMIT提交或者ROLLBACK回滚。修改AUTOCOMMIT对于非事务型的表，比如MyISAM或者内存表，不会有任何影响，对于这类表，没有COMMIT和ROLLBACK的概念，也可以说一直处于AUTOCOMMIT启用的模式。

MySQL可以通过执行SET TRANSACTION ISOLATION LEVEL 命令来设置隔离级别。新的隔离级别也会在下个事务开始的时候生效，可以在配置文件中设置整个数据库的隔离级别，也可以只改变当前会话的隔离级别。

```sql
SET SESSION TRANSACTION ISOLATION LEVEL READ COMMITTED;
```

MySQL 能够识别所有的4个 ANSI 隔离级别， InnoDB 引擎也支持所有的隔离级别。



#### 在事务中混合使用存储引擎

MySQL服务器层不管理事务，事务是由下层存储引擎实现的。所以在同一个事务中，使用多种存储引擎是不可靠的。

#### 隐式和显示锁定

InnoDB采用的是两阶段锁定协议（two-phase locking protocol）。在事务执行过程中，随时可以执行锁定，锁只有在执行COMMIT或者ROLLBACK的时候才会释放，并且所有的锁是在同一时刻被释放。并且所有的锁同一时刻被释放。

另外InnoDB也可以通过特定语句进行显示锁定，这些语句不属于SQL规范

```sql
SELECT ... LOCK IN SHARE MODE
SELECT ... FOR UPDATE
```

MySQL也支持LOCK TABLES和UNLOCK TABLES 语句， 这些都是在服务器层实现的，和存储引擎无关。他们有自己的用途，但是并不能代替事务处理。

> LOCK TABLES 和事务之间相互印象的话，情况会变得非常负责， 建议：除了在事务中禁用了AUTOCOMMIT， 可以使用LOCK TABLES 之外，其他任何情况都不要显示的执行LOCK TABLES

## 1.4 多版本并发控制

MySQL的大多数事务型存储引擎，都不是简单的行级锁。基于提升并发性能的考虑，他们一般都同时实现了多版本并发控制（MVCC mutiversion concurrency control）

可以认为MVCC是行级锁的一个变种，但是他在很多情况下避免了加锁操作，因此开销更低。虽然实现机制有所不同，但大都实现了非阻塞的读操作，写操作也只锁定必要的行。

MVCC的实现，是通过保存数据在某个时间点的快照来实现的。也就是说，不管需要执行多长时间，每个事务看到的数据都是一致的。根据事务开始的时间不同，每个事务对同一张表，同一时刻看到的数据可能是不一样的。

MVCC的实现典型的有

* 乐观（optimistic）并发控制
* 悲观（pessimistic）并发控制

InnoDB的mVCC是通过在每行记录后面保存两个隐藏的列来实现的。 这两个列，一个保存了行的创建时间，一个保存行的过期时间（删除时间）。当然存储的并不是实际的时间值，而是系统版本号（system version number）。每开始一个新的事务，系统版本号会自动递增。事务开始时刻的系统版本号 会作为事务的版本号。用来和查询到的每行记录的版本号进行比较。 在REPEATABLE READ 隔离级别下 MVCC具体如何操作：

* SELECT  InnoDB会根据两个条件检查每行记录
  * InnoDB只查找版本早于当前事务版本的数据行（行的系统版本号小于或等于事务的系统版本号），这样可以确保事务读取的行，要么是在事务开始前已经存在的，要么是事务本身插入或者修改过的
  * 行的删除版本要么未定义，要么大于当前十五版本号。这样可以确保事务读取到的行，在事务开始之前未被删除。
* INSERT ： InnoDB为新插入的每一行保存当前系统版本号作为行版本啊荷藕
* DELETE：为删除的每一行保存当前系统版本号作为行版本号
* UPDATE ： InnoDB为插入一行新记录，保存当前系统版本号作为行版本号，同事保存当前系统版本号到原来的行作为行删除标识。

MVCC只在REPEATABLE READ 和 READ COMMITTED两个隔离级别下工作。

## 1.5 MySQL的存储引擎

在文件系统中，MySQL将每个数据库（也可以称之为schema）保存为数据目录下的一个子目录。创建表时，MySQL会在数据库子目录下创建一个和表名同名的.frm 文件，保存表的定义。



![1528872377778](C:\Users\dongzc15247.HS\Desktop\note\mysql\images\3.png)

* Name 表名
* Engine 表的存储引擎类型。
* 行的格式。对于MyISAM表 可选的值为Dynamic, Fixed或者 Compressed 
  * Dynamic的行长度是可变的，一般包含可变长度的字段，如 VARCHAR 或 BLOB
  * Fixed的行长度则是固定的，只包含固定长度的列， 如CHAR 和 INTEGER
  * Compressed的行只在压缩表中存在
* Rows：表中的行数。对于MyISAM和其他一些存储引擎，该值是精确的， 但对于InnoDB该值是估计值
* Avg_row_length： 平均每行包含的字节数
* Data_length：表数据的大小（以字节为单位）
* Max_data_length：表数据最大容量，该值和存储引擎有关。

![1528876747613](C:\Users\dongzc15247.HS\Desktop\note\mysql\images\1528876747613.png)

### 1.5.1 InnoDB存储引擎

是MySQL的默认事务引擎，也是最重要使用最广泛的存储引擎。

InnoDB的数据存储在表空间（tablespace）中，表空间是由InnoDB管理的黑盒子，由一系列数据文件组成。

采用MVCC来支持高并发，并且实现了四个标准的隔离级别，默认级别是REPEATABLE READ（可重复读），并且通过间隙锁（next-key locking）策略防止幻读的出现。

InnoDB表是基于聚簇索引创建的。聚簇索引对主键查询有很高的性能。不过他的二级索引（非主键索引）中必须包含主键列，所以如果注解列很大的话没其他所有索引都会很大。

InnoDB的存储格式是平台独立的，也就是说可以将数据和索引文件从Intel平台复制到其他平台。

### 1.5.2 MyISAM 存储引擎

# 二、MySQL基准测试（benchmark）



