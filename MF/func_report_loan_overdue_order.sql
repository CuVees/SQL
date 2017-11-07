BEGIN  
delete from reportdb.report_loan_overdue_order; 
insert into  reportdb.report_loan_overdue_order(day_key,type,is_new,should_back_cnt,front_repay,normal_repay,overdue_repay,untill_overdue)
select  
t1.day_key as day_key
,(case when t1.user_id is not null and t1.credit_id<>t1.id then 0 else 1 end) is_new
,t1.type as type
,count(distinct t1.id) as should_back_cnt
,count(distinct case when is_front='1' then t2.credit_id else null end) as front_repay
,count(distinct case when is_front='0' then t2.credit_id else null end) as normal_repay

,count(distinct case when is_front='-1' then t1.id else null end) as overdue_repay


,count(distinct case when t1.status in(6,8) then t1.id else null end) as untill_overdue
from  
	(
		select 
		a1.day_key
		,a1.type
		,a1.id
		,a1.status
		,a2.credit_id
		,a2.user_id
		from 
		(
			select 
			date(shouldback_time) as day_key
			,(case when product_id in(1,3) then '7天' when  product_id in(2,4) then '14天' else 0 end) as type
			,id
			,uid
			,status
			from  bmdb.tb_credit_record 
			where  shouldback_time>='2017-05-01' and shouldback_time <= now() 
			
			group by 1,2,3,4,5
		) a1 left join
		(
			select user_id,credit_id from reportdb.agg_first_success_loan_repay_user 
		)a2 on a1.uid=a2.user_id 
		
		group by a1.day_key,a1.type,a1.id,a1.status,a2.credit_id,a2.user_id
	)t1 left  join
	(
		select 
		credit_id
		,(case when date(normal_time) > date(actual_time) then '1' 
		when date(normal_time) = date(actual_time) then '0' 
		when date(normal_time) < date(actual_time) then '-1' end ) as is_front
		from  bmdb.tb_repayment_record 
		group by 1,2
	)t2  on t1.id=t2.credit_id  
	group by t1.day_key,t1.type,2;

  RETURN 1;  
END