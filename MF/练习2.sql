#老用户
select 
	t1.day_key as 申请日期
	,count(distinct t1.id) as 申请订单数
	,count(distinct t1.id)-count(distinct t2.id) as 有效订单
	,count(distinct case when t3.status in(1,2,3,4,5,6,7,8) then t3.id  
						 else null end) as 进入人工审核
	,count(distinct case when t3.status in(2,3,5,6,7,8) then t3.id  
						 else null end) as 人工审核通过
	,sum( case when t3.status in(2,3,5,6,7,8) then t3.actual_balance  
		       else 0 
		   end) as 放款金额
from 
(
 	SELECT 
 		date(created_time) as day_key
 		,id
  	FROM bmdb.tb_credit_record
  	WHERE DATE(created_time) >= date_sub(curdate(), interval 15 day) and  DATE(created_time) < curdate() AND uid  in 
  			(SELECT uid 
  			 FROM bmdb.tb_credit_record 
  			 WHERE status in (5,7))
    group by date(created_time),id
) t1 
left join
(
 	#无效订单
 	SELECT 
 		cr.id
 		,DATE(cr.created_time) as day_key
 	FROM bmdb.tb_credit_record  cr, bmdb.tb_score_rule_result sr 
 	WHERE cr.id = sr.credit_id #and DATE(cr.created_time) = '2017-07-19' 
 		and sr.status = 1 and risk_type  LIKE 'N%'
 		AND cr.uid  in (SELECT uid FROM bmdb.tb_credit_record WHERE status in (5,7))
 	group by cr.id 
)t2 
on  
	t1.id=t2.id and t1.day_key=t2.day_key  
left join 
(
 	#进入人工审核量
 	SELECT 
 		id
 		,status
 		,actual_balance
 	FROM bmdb.tb_credit_record  cr
 	WHERE cr.uid  in (SELECT uid FROM bmdb.tb_credit_record WHERE status in (5,7))
 	group by id ,status,actual_balance
)t3 
on 
	t1.id=t3.id 
GROUP BY t1.day_key
ORDER BY 1 desc