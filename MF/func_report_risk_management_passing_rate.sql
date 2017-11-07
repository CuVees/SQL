BEGIN  

delete from reportdb.report_risk_management_passing_rate where day_key=idate ;

insert into reportdb.report_risk_management_passing_rate(day_key,user_type,order_cnt,effective_order_cnt,rule_cnt,modle_cnt,tongdun_cnt

,tongdun_modle_cnt,face_cnt,manual_order_cnt,suc_manual_order_cnt,suc_amount)



select 

e1.day_key as day_key

,'new_user' as user_type

,e1.order_cnt as order_cnt

,e1.effective_order_cnt

,(e1.effective_order_cnt-COALESCE(e2.rule_refuse,0)) as rule_cnt

,(e1.effective_order_cnt-COALESCE(e2.rule_refuse,0)-COALESCE(e3.modle_refuse,0)) as modle_cnt

,(e1.effective_order_cnt-COALESCE(e2.rule_refuse,0)-COALESCE(e3.modle_refuse,0)-COALESCE(e4.tongdun_refuse,0)) as tongdun_cnt

,(e1.effective_order_cnt-COALESCE(e2.rule_refuse,0)-COALESCE(e3.modle_refuse,0)-COALESCE(e4.tongdun_refuse,0)-COALESCE(e6.tongdun_modle_refuse,0)) as tongdun_modle_cnt

,(e1.effective_order_cnt-COALESCE(e2.rule_refuse,0)-COALESCE(e3.modle_refuse,0)-COALESCE(e4.tongdun_refuse,0)-COALESCE(e6.tongdun_modle_refuse,0)-COALESCE(e5.face_refuse,0)) as face_cnt 

,e1.manual_order_cnt as manual_order_cnt

,e1.suc_manual_order_cnt  as suc_manual_order_cnt

,e1.suc_amount as suc_amount

from

(  


	select 

	t1.day_key

	,count(distinct t1.id) as order_cnt

	,count(distinct t1.id)-count(distinct t2.id) as effective_order_cnt

	,count(distinct case when t1.status in(1,2,3,4,5,6,7,8) then t1.id  else null end) as manual_order_cnt

	,count(distinct case when t1.status in(2,3,5,6,7,8) then t1.id  else null end) as suc_manual_order_cnt

	,sum( case when t1.status in(2,3,5,6,7,8) then t1.actual_balance  else 0 end) as suc_amount

	from 

	(

		select 

		b1.day_key

		,b1.id

		,b1.status

		,b1.actual_balance

		from

		(

			SELECT 

			date(created_time) as day_key

			,id

			,uid

			,status

			,actual_balance

			FROM bmdb.tb_credit_record

			WHERE DATE(created_time) >= idate  and DATE(created_time) < date_add(idate,INTERVAL 1 DAY)

			group by date(created_time),id,status,actual_balance,uid

		)b1 left join 

		(

			select user_id,credit_id from reportdb.agg_first_success_loan_repay_user

		)b2 on b1.uid=b2.user_id

		where (b2.user_id is  null or b2.credit_id=b1.id)

		group by 1,2,3,4

	)t1 left join

	(

		
		select 

		a1.day_key

		,a1.id

		from

		(

			SELECT 

			cr.id

			,cr.uid

			,DATE(cr.created_time) as day_key

			FROM bmdb.tb_credit_record  cr, bmdb.tb_score_rule_result sr 

			WHERE cr.id = sr.credit_id and sr.status = 1 and risk_type  LIKE 'N%'

			and DATE(cr.created_time) >= idate and DATE(cr.created_time) < date_add(idate,INTERVAL 1 DAY) 

			group by 1,2,3

		)a1 left join

		(

			select user_id,credit_id from reportdb.agg_first_success_loan_repay_user

		)a2 on a1.uid=a2.user_id

		where (a2.user_id is  null or a2.credit_id=a1.id)

		group by 1,2

	)t2 on  t1.id=t2.id and t1.day_key=t2.day_key

	GROUP BY t1.day_key

)e1 left join

(


	SELECT 

	DATE(cr.created_time) as day_key

	,COUNT(cr.id) as rule_refuse

	FROM bmdb.tb_credit_record cr, bmdb.tb_score_result sr

	where cr.id = sr.credit_id and sr.status = 2 

	and DATE(cr.created_time)>=idate and DATE(cr.created_time)< date_add(idate,INTERVAL 1 DAY)

	group by DATE(cr.created_time)

) e2 on e1.day_key=e2.day_key left join

(


	SELECT 

	DATE(cr.created_time) as day_key

	,COUNT(cr.id) as modle_refuse

	FROM bmdb.tb_credit_record cr, bmdb.tb_score_result sr

	where cr.id = sr.credit_id and sr.status = 3 

	and DATE(cr.created_time)>=idate and DATE(cr.created_time)<date_add(idate,INTERVAL 1 DAY)

	group by DATE(cr.created_time)

)e3 on  e1.day_key=e3.day_key left join

(


	SELECT 

	DATE(cr.created_time) as day_key

	,COUNT(cr.id) as tongdun_refuse

	FROM bmdb.tb_credit_record cr, bmdb.tb_score_result sr

	where cr.id = sr.credit_id and sr.status = 4 

	and DATE(cr.created_time)>=idate and DATE(cr.created_time)< date_add(idate,INTERVAL 1 DAY)

	group by DATE(cr.created_time)

)e4 on e1.day_key=e4.day_key left join

(


	SELECT 

	DATE(cr.created_time) as day_key

	,COUNT(cr.id) as face_refuse

	FROM bmdb.tb_credit_record cr, bmdb.tb_score_result sr

	where cr.id = sr.credit_id and sr.status = 5 

	and DATE(cr.created_time)>= idate and DATE(cr.created_time)<date_add(idate,INTERVAL 1 DAY)

	group by DATE(cr.created_time)

)e5 on e1.day_key=e5.day_key left join

(


	SELECT 

	DATE(cr.created_time) as day_key

	,COUNT(cr.id) as tongdun_modle_refuse

	FROM bmdb.tb_credit_record cr, bmdb.tb_score_result sr

	where cr.id = sr.credit_id and sr.status = 6 

	and DATE(cr.created_time)>=idate and DATE(cr.created_time)<date_add(idate,INTERVAL 1 DAY)

	group by DATE(cr.created_time)

)e6 on e1.day_key=e6.day_key

group by 1,2,3,4,5,6,7,8,9,10,11,12

union all 

select 

e1.day_key as  day_key 

,'old_user' as user_type

,e1.order_cnt as  order_cnt

,e1.effective_order_cnt as effective_order_cnt

,(e1.effective_order_cnt-COALESCE(e2.rule_refuse,0)) as rule_cnt

,(e1.effective_order_cnt-COALESCE(e2.rule_refuse,0)-COALESCE(e3.modle_refuse,0)) as modle_cnt

,(e1.effective_order_cnt-COALESCE(e2.rule_refuse,0)-COALESCE(e3.modle_refuse,0)-COALESCE(e4.tongdun_refuse,0)) as tongdun_cnt

,0 as tongdun_modle_cnt

,(e1.effective_order_cnt-COALESCE(e2.rule_refuse,0)-COALESCE(e3.modle_refuse,0)-COALESCE(e4.tongdun_refuse,0)-COALESCE(e5.face_refuse,0)) as face_cnt

,e1.manual_order_cnt as manual_order_cnt

,e1.suc_manual_order_cnt as suc_manual_order_cnt

,e1.suc_amount as suc_amount

from

(  

	select 

	t1.day_key

	,count(distinct t1.id) as order_cnt

	,count(distinct t1.id)-COALESCE(count(distinct t2.id), 0) as effective_order_cnt

	,count(distinct case when t1.status in(1,2,3,4,5,6,7,8) then t1.id  else null end) as manual_order_cnt

	,count(distinct case when t1.status in(2,3,5,6,7,8) then t1.id  else null end) as suc_manual_order_cnt

	,sum( case when t1.status in(2,3,5,6,7,8) then t1.actual_balance  else 0 end) as suc_amount

	from 

	(

		select 

		b1.day_key

		,b1.id

		,b1.status

		,b1.actual_balance

		from

		(

			SELECT 

			date(created_time) as day_key

			,id

			,uid

			,status

			,actual_balance

			FROM bmdb.tb_credit_record

			WHERE DATE(created_time) >= idate  and DATE(created_time) < date_add(idate,INTERVAL 1 DAY)

			group by date(created_time),id,status,actual_balance,uid

		)b1 left join 

		(

			select user_id,credit_id from reportdb.agg_first_success_loan_repay_user

		)b2 on b1.uid=b2.user_id

		where b2.user_id is not null and b2.credit_id<>b1.id

		group by 1,2,3,4

	)t1 left join

	(

	
		select 

		a1.day_key

		,a1.id

		from

		(

			SELECT 

			cr.id

			,cr.uid

			,DATE(cr.created_time) as day_key

			FROM bmdb.tb_credit_record  cr, bmdb.tb_score_rule_result sr 

			WHERE cr.id = sr.credit_id and sr.status = 1 and risk_type  LIKE 'N%'

			and DATE(cr.created_time) >= idate and DATE(cr.created_time) < date_add(idate,INTERVAL 1 DAY)

			group by 1,2,3

		)a1 left join

		(

			select user_id,credit_id from reportdb.agg_first_success_loan_repay_user

		)a2 on a1.uid=a2.user_id

		where a2.user_id is not null and a2.credit_id<>a1.id

		group by 1,2

	)t2 on  t1.id=t2.id and t1.day_key=t2.day_key

	GROUP BY t1.day_key

)e1 left join

(


	SELECT 

	DATE(cr.created_time) as day_key

	,COUNT(cr.id) as rule_refuse

	FROM bmdb.tb_credit_record cr, bmdb.tb_score_result sr

	where cr.id = sr.credit_id and sr.status = 102 

	and DATE(cr.created_time)>=idate and DATE(cr.created_time)< date_add(idate,INTERVAL 1 DAY)

	group by DATE(cr.created_time)

) e2 on e1.day_key=e2.day_key left join

(


	SELECT 

	DATE(cr.created_time) as day_key

	,COUNT(cr.id) as modle_refuse

	FROM bmdb.tb_credit_record cr, bmdb.tb_score_result sr

	where cr.id = sr.credit_id and sr.status = 103 

	and DATE(cr.created_time)>=idate and DATE(cr.created_time)<date_add(idate,INTERVAL 1 DAY)

	group by DATE(cr.created_time)

)e3 on  e1.day_key=e3.day_key left join

(


	SELECT 

	DATE(cr.created_time) as day_key

	,COUNT(cr.id) as tongdun_refuse

	FROM bmdb.tb_credit_record cr, bmdb.tb_score_result sr

	where cr.id = sr.credit_id and sr.status = 104 

	and DATE(cr.created_time)>=idate and DATE(cr.created_time)<date_add(idate,INTERVAL 1 DAY)

	group by DATE(cr.created_time)

)e4 on e1.day_key=e4.day_key left join

(


	SELECT 

	DATE(cr.created_time) as day_key

	,COUNT(cr.id) as face_refuse

	FROM bmdb.tb_credit_record cr, bmdb.tb_score_result sr

	where cr.id = sr.credit_id and sr.status = 105 

	and DATE(cr.created_time)>=idate and DATE(cr.created_time)<date_add(idate,INTERVAL 1 DAY)

	group by DATE(cr.created_time)

)e5 on e1.day_key=e5.day_key

group by 1,2,3,4,5,6,7,8,9,10,11,12;

RETURN 1;  

END