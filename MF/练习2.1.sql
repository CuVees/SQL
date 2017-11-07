select 
	t1.day_key as 申请日期,
	count(distinct t1.id) as 申请订单数,
	count(distinct t1.id) - count(distinct t2.id) as 有效订单数,
	count(distinct case when t3.status in (1,2,3,4,5,6,7,8) then t3.id
						else null
				   end) as 进入人工审核,
	count(distinct case when t3.status in (2,3,5,6,7,8) then t3.id
						else null
				   end) as 人工审核通过,
	sum(case when t3.status in (2,3,5,6,7,8) then t3.actaual_balance
		     else 0
		end) as 放款金额
from
(
	select
		date(created_time) as day_key,
		id
	from 
		bmdb.tb_credit_record
	where 
		date(created_time)>=date_sub(curdate(),interval 15 day) and date(created_time)<=curdate() and uid in (select
																													uid
																											  from 
																											  		bmdb.tb_credit_record
																											  where 
																											    	status in (5,7)
																											   )
	group by date(created_time),id

) t1
left join
(
	select 
		cr.id,
		date(cr.created_time) as dat_ket
	from 
		bmdb.tb_credit_record cr,bmdb.tb_score_rule_result sr
	where cr.id = sr.credit_id and sr.status=1 and risk_type like "N%" and cr.uid in (select
																							uid
																					  from
																					  		bmdb.tb_credit_record
																					  where
																					  		status in (5,7)
																					  )
	group by cr.id
) t2
on 
	t1.id=t2.id and t1.day_key=t2.day_key
left join
(
	SELECT 
 		id,
 		status,
 		actual_balance
 	FROM bmdb.tb_credit_record  cr
 	WHERE cr.uid  in (SELECT 
 							uid 
 					  FROM 
 					  		bmdb.tb_credit_record 
 					  WHERE 
 					  		status in (5,7)
 					  )
 	group by id ,status,actual_balance
)t3 
on 
	t1.id=t3.id 
GROUP BY t1.day_key
ORDER BY 1 desc