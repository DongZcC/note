

DROP TABLE IF EXISTS `Department`;
create table `Department` (
	`id` bigint(20) NOT NULL AUTO_INCREMENT,
	`departmentName` varchar(20),
	PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8  COMMENT='部门表';

DROP TABLE IF EXISTS `employee`;

create table `employee` (
	`id` bigint(20) NOT NULL AUTO_INCREMENT,
	`lastName` varchar(20),
	`email` varchar(20),
	`gender` int,
	`d_id` bigint(20) ,
	PRIMARY KEY (`id`),
	FOREIGN KEY (d_id) REFERENCES Department(id)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8  COMMENT='员工表';