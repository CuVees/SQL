---------------------------
DELIMITER $$
CREATE FUNCTION reportdb.func_report_jiedai_funnel(idate date)
RETURNS TINYINT 
BEGIN
DELETE FROM reportdb.report_jiedai_funnel where day_key=idate
INSERT INTO reportdb.report_jiedai_funnel (day_key ,reg_cnt ,shiming_cnt,zhima_cnt,bank_cnt,urgency_cnt,tongxunlv_cnt,mobile_cnt ,geren_cnt,liveness_cnt,submit_cnt,client_type)
SELECT
	t1.day_key as day_key,
	count(DISTINCT t1.uid) as reg_cnt,
	count(DISTINCT t2.uid) as shiming_cnt,
	count(DISTINCT t3.uid) as zhima_cnt,
	count(DISTINCT t4.uid) as bank_cnt,
	count(DISTINCT t5.uid) as urgency_cnt,
	count(DISTINCT t6.user_id) as tongxunlv_cnt,
	count(case when is_mobile=1 and t1.day_key=mobile_time then t1.uid end) as mobile_cnt,
	count(case when is_geren=1 and t1.day_key=geren_time then t1.uid end) as geren_cnt
	count(case when is_liveness=1 and t1.day_key=liveness_time then t1.uid end) as liveness_cnt
	count(DISTINCT t8.id) as submit_cnt,
	t1.client_type as client_type
FROM
(
	SELECT a.day_key as day_key,a.uid as uid,b.client_type as client_type
	FROM
	(
		SELECT date(created) as day_key,id as uid
		FROM bmdb.tb_user
		WHERE created>=idate and created<date_add(idate,INTERVAL 1 DAY)
		GROUP BY 1,2
	) a
	LEFT JOIN
	(
		SELECT user_id as uid,client_type
		FROM bmdb.tb_user_phone_adapter
		WHERE created>=idate and created<date_add(idate,INTERVAL 1 day)
		GROUP BY 1,2
	) b
	ON
		a.uid=b.uid
) t1
LEFT JOIN
(
	# 实名
	SELECT date(create_time) as day_key,uid
	FROM bmdb.tb_shiming_record
	WHERE create_time>=idate and create_time<date_add(idate,INTERVAL 1 DAY)
	GROUP BY 1,2
) t2
ON t1.uid=t2.uid and t1.day_key=t2.day_key
LEFT JOIN
(
	# 芝麻
	SELECT date(create_time) as day_key,uid
	FROM bmdb.tb_zhima_record
	WHERE create_time>=idate and create_time<date_add(idate,INTERVAL 1 DAY)
	GROUP BY 1,2
) t3
ON t1.uid=t3.uid and t1.day_key=t3.day_key
LEFT JOIN
(
    # 银行卡
	SELECT date(create_time) as day_key,uid
	FROM bmdb.tb_userbank_record
	WHERE create_time>=idate and create_time<date_add(idate,INTERVAL 1 DAY)
	GROUP BY 1,2
) t4
ON t1.uid=t4.uid and t1.day_key=t4.day_key
LEFT JOIN
(
	# 紧急联系人
	SELECT date(create_time) as day_key,uid
	FROM bmdb.tb_urgency
	WHERE create_time>=idate and create_time<date_add(idate,INTERVAL 1 DAY)
	GROUP BY 1,2
) t5
ON t1.uid=t5.uid and t1.day_key=t5.day_key
LEFT JOIN
(
	# 通讯录
	SELECT date(create_time) as day_key,user_id
	FROM bmdb.tb_user_addresslist
	WHERE created>=idate and created<date_add(idate,INTERVAL 1 DAY)
	GROUP BY 1,2
) t6
ON t1.uid=t6.user_id and t1.day_key=t6.day_key
LEFT JOIN
(
	# 手机认证，个人认证，活体认证
	SELECT user_id,is_mobile,date(mobile_time) as mobile_time,
		   is_geren,date(geren_time) as geren_time,is_liveness,date(liveness_time) as liveness_time
    FROM bmdb.tb_user_task
    GROUP by 1,2,3,4,5,6,7
) t7
ON t1.uid=t7.user_id
LEFT JOIN
(
	SELECT uid,id,date(created_time) as day_key
	FROM bmdb.tb_credit_record
	WHERE created_time>=idate and created_time<date_add(idate,INTERVAL 1 DAY)
	GROUP 1,2,3
) t8
ON t1.uid=t8.uid
GROUP BY 1,client_type;
return 1;
END $$
DELIMITER;

-------------------------
create table reportdb.report_jiedai_funnel
(
	id int(11) NOT NULL AUTO_INCREMENT COMMENT '主键',
	day_key date DEFAULT NULL COMMENT '日期',
	reg_cnt int(4) DEFAULT 0 COMMENT '注册人数',
	shiming_cnt int(4) DEFAULT 0 COMMENT '实名人数',
	zhima_cnt int(4) DEFAULT 0 COMMENT '芝麻认证人数',
	bank_cnt int(4) DEFAULT 0 COMMENT '绑卡人数',
	urgency_cnt int(4) DEFAULT 0 COMMENT  '紧急联系人数',
	tongxunlv_cnt int(4) DEFAULT 0 COMMENT  '通讯录人数',
	mobile_cnt int(4) DEFAULT 0 COMMENT  '运营商认证',
	geren_cnt int(4) DEFAULT 0 COMMENT  '个人信息认证',
	liveness_cnt int(4) DEFAULT 0 COMMENT  '人脸认证',
	submit_cnt int(4) DEFAULT 0 COMMENT  '提交订单人数',
	inserttime timestamp NOT NULL DEFAULT current_timestamp COMMENT '插入时间',
	client_type int,
	primary key(`id`)
)COMMENT '借贷每日漏斗数据'



