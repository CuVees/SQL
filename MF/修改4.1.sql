select DATE_FORMAT(t.arrive_time,'%Y-%m') 放款月,

COALESCE(sum(case when t.actual_time is not null and  t.overdue=1 and t.dq_days>=1 AND is_status =1 then 1  else 0 end)/sum(case when  t.overdue>0 and t.dq_days>=1 then 1  else 0 end),0)'T+1日回收(老客)',
COALESCE(sum(case when t.actual_time is not null and  t.overdue=1 and t.dq_days>=1 AND is_status =2 then 1  else 0 end)/sum(case when  t.overdue>0 and t.dq_days>=1 then 1  else 0 end),0)'T+1日回收(新客)',

COALESCE(sum(case when t.actual_time is not null and  t.overdue BETWEEN 1 and 3 and t.dq_days>=3 AND is_status =1 then 1  else 0 end)/sum(case when  t.overdue>0 and t.dq_days>=3 then 1  else 0 end),0)'T+3日回收(老客)',
COALESCE(sum(case when t.actual_time is not null and  t.overdue BETWEEN 1 and 3 and t.dq_days>=3 AND is_status =2 then 1  else 0 end)/sum(case when  t.overdue>0 and t.dq_days>=3 then 1  else 0 end),0)'T+3日回收(新客)',

COALESCE(sum(case when t.actual_time is not null and  t.overdue BETWEEN 1 and 5 and t.dq_days>=5 AND is_status =1 then 1  else 0 end)/sum(case when  t.overdue>0 and t.dq_days>=5 then 1  else 0 end),0)'T+5日回收(老客)',
COALESCE(sum(case when t.actual_time is not null and  t.overdue BETWEEN 1 and 5 and t.dq_days>=5 AND is_status =2 then 1  else 0 end)/sum(case when  t.overdue>0 and t.dq_days>=5 then 1  else 0 end),0)'T+5日回收(新客)',

COALESCE(sum(case when t.actual_time is not null and  t.overdue BETWEEN 1 and 7 and t.dq_days>=7 and is_status =1 then 1  else 0 end)/sum(case when  t.overdue>0 and t.dq_days>=7 then 1  else 0 end),0)'T+7日回收(老客)',
COALESCE(sum(case when t.actual_time is not null and  t.overdue BETWEEN 1 and 7 and t.dq_days>=7 and is_status =2 then 1  else 0 end)/sum(case when  t.overdue>0 and t.dq_days>=7 then 1  else 0 end),0)'T+7日回收(新客)',

COALESCE(sum(case when t.actual_time is not null and  t.overdue BETWEEN 1 and 15 and t.dq_days>=15 and is_status =1 then 1  else 0 end)/sum(case when  t.overdue>0 and t.dq_days>=15 then 1  else 0 end),0)'T+15日回收(老客)',
COALESCE(sum(case when t.actual_time is not null and  t.overdue BETWEEN 1 and 15 and t.dq_days>=15 and is_status =2 then 1  else 0 end)/sum(case when  t.overdue>0 and t.dq_days>=15 then 1  else 0 end),0)'T+15日回收(新客)',

COALESCE(sum(case when t.actual_time is not null and  t.overdue BETWEEN 1 and 20 and t.dq_days>=20 and is_status =1 then 1  else 0 end)/sum(case when  t.overdue>0 and t.dq_days>=20 then 1  else 0 end),0)'T+20日回收(老客)',
COALESCE(sum(case when t.actual_time is not null and  t.overdue BETWEEN 1 and 20 and t.dq_days>=20 and is_status =2 then 1  else 0 end)/sum(case when  t.overdue>0 and t.dq_days>=20 then 1  else 0 end),0)'T+20日回收(新客)',

COALESCE(sum(case when t.actual_time is not null and  t.overdue BETWEEN 1 and 25 and t.dq_days>=25 and is_status =1 then 1  else 0 end)/sum(case when  t.overdue>0 and t.dq_days>=25 then 1  else 0 end),0)'T+25日回收(老客)',
COALESCE(sum(case when t.actual_time is not null and  t.overdue BETWEEN 1 and 25 and t.dq_days>=25 and is_status =2 then 1  else 0 end)/sum(case when  t.overdue>0 and t.dq_days>=25 then 1  else 0 end),0)'T+25日回收(新客)',

COALESCE(sum(case when t.actual_time is not null and  t.overdue BETWEEN 1 and 30 and t.dq_days>=30 and  is_status =1 then 1  else 0 end)/sum(case when  t.overdue>0 and t.dq_days>=30 then 1  else 0 end),0)'T+30日回收(老客)',
COALESCE(sum(case when t.actual_time is not null and  t.overdue BETWEEN 1 and 30 and t.dq_days>=30 and is_status =2 then 1  else 0 end)/sum(case when  t.overdue>0 and t.dq_days>=30 then 1  else 0 end),0)'T+30日回收(新客)'
from 
(
SELECT cr.id,cr.uid,cr.`name`,cr.dentity_card,cr.tel,cr.balance,cr.cycle,cr.created_time,cr.arrive_time,cr.actual_balance,cr.fee,cr.product_id,cr.`status`,
       case when cr.`status` in (2,3,5,6,7,8,9,10,11) then 1 else 0 end as is_pass,
       case when cr.shouldback_time is not null then 1 else 0 end as is_fk,
       case when cr.shouldback_time is not null and rr.actual_time is not null then 1 
            when cr.shouldback_time is not null and rr.actual_time is null then 0
            else null end as is_clear, 
       cr.shouldback_time,rr.actual_time,
       case when cr.shouldback_time<now() and rr.actual_time is null then DATEDIFF(now(),cr.shouldback_time)
            when rr.actual_time is not null then DATEDIFF(rr.actual_time,cr.shouldback_time) 
            else null end as  overdue,
       case when  rr.actual_time is null and cr.shouldback_time<now() then DATEDIFF(now(),cr.shouldback_time)
            else null end as overdue_cur,
       DATEDIFF(NOW(),cr.shouldback_time) dq_days,

			CASE WHEN cr.task_status=4 THEN 1
				   WHEN cr.task_status in (1,2,3) THEN 2
           ELSE null END as is_status,


       rr.actual_fee
from bmdb.tb_credit_record cr 
left join bmdb.tb_repayment_record rr
on cr.id=rr.credit_id
where cr.shouldback_time is not null  and  cr.arrive_time>='2017-05-01'
)t
GROUP BY 1