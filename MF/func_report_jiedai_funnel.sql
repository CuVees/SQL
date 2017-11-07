BEGIN
delete from reportdb.report_jiedai_funnel where day_key = idate;
insert into reportdb.report_jiedai_funnel
	(day_key ,reg_cnt ,shiming_cnt,zhima_cnt,bank_cnt,urgency_cnt,tongxunlv_cnt,mobile_cnt ,geren_cnt,liveness_cnt,submit_cnt,client_type)
select 
	t1.day_key as day_key,
	count(DISTINCT t1.uid) as reg_cnt,
	count(DISTINCT t2.uid) as shiming_cnt,
	count(DISTINCT t3.uid) as zhima_cnt,
	count(DISTINCT t4.uid) as bank_cnt,
	count(DISTINCT t5.uid) as urgency_cnt,
	count(DISTINCT t6.user_id) as tongxunlv_cnt,
	count(DISTINCT case when 
						is_mobile=1 and t1.day_key=mobile_time then t1.uid
					end) as mobile_cnt,
	count(DISTINCT case when 
						is_geren=1 and t1.day_key=geren_time then t1.uid
					end) as geren_cnt,	
	count(DISTINCT case when 
						is_liveness=1 and t1.day_key=liveness_time then t1.uid
					end) as liveness_cnt,	
	count(DISTINCT t8.id) as submit_cnt,
	t1.client_type as client_type
from (
	# 注册
	select date(created) as day_key,user_id as uid,client_type
	from bmdb.tb_user_phone_adapter where created>=idate and created<=date_add(idate,INTERVAL 1 DAY)
	group by 1,2,3) t1
left join (
	# 实名
	select date(create_time) as day_key,uid
	from bmdb.tb_shiming_record where create_time>=idate and create_time<=date_add(idate,INTERVAL 1 DAY)
	group by 1,2) t2
on 	
	t1.uid = t2.uid and t1.day_key=t2.day_key
left join(
	# 芝麻
	select date(create_time) as day_key,uid
	from bmdb.tb_zhima_credit where create_time>=idate and create_time<=date_add(idate,INTERVAL 1 DAY)
	group by 1,2) t3
on 
	t1.uid=t3.uid and t1.day_key=t3.day_key	
left join(
	#银行卡
	select date(create_time) as day_key,uid
	FROM bmdb.tb_userbank_record where create_time>=idate and create_time<date_add(idate,INTERVAL 1 DAY)
	group by  1,2) t4
on 
	t1.uid=t4.uid and  t1.day_key=t4.day_key 
left join(
	#紧急联系人
	select date(create_time) as day_key,uid 
	from bmdb.tb_urgency where create_time>=idate and create_time<date_add(idate,INTERVAL 1 DAY)
group by 1,2

)
	
