select 
DATE_FORMAT(t.arrive_time,'%Y-%m')放款月,
COALESCE(sum(case when dq_days>0 AND overdue>=1 then 1 else 0 end)/sum(case when dq_days>=1 then 1 else 0 end),0) '逾期率(1天)',
COALESCE(sum(case when dq_days>0 AND overdue>=3 then 1 else 0 end)/sum(case when dq_days>=3 then 1 else 0 end),0) '逾期率(3天)',
COALESCE(sum(case when dq_days>0 AND overdue>=7 then 1 else 0 end)/sum(case when dq_days>=7 then 1 else 0 end),0) '逾期率(7天)',
COALESCE(sum(case when dq_days>0 AND overdue>=15 then 1 else 0 end)/sum(case when dq_days>=15 then 1 else 0 end),0) '逾期率(15天)',
COALESCE(sum(case when dq_days>0 AND overdue>=30 then 1 else 0 end)/sum(case when dq_days>=30 then 1 else 0 end),0) '逾期率(30天)',
COALESCE(sum(case when dq_days>0 AND overdue>=60 then 1 else 0 end)/sum(case when dq_days>=60 then 1 else 0 end),0) '逾期率(60天)',
COALESCE(sum(case when dq_days>0 AND overdue>=90 then 1 else 0 end)/sum(case when dq_days>=90 then 1 else 0 end),0) '逾期率(90天)'
from 
(
SELECT 
cr.id,cr.dentity_card,cr.cycle,cr.created_time,cr.arrive_time,
cr.shouldback_time,rr.actual_time,
case when cr.shouldback_time<now() and rr.actual_time is null then DATEDIFF(now(),cr.shouldback_time)
when rr.actual_time is not null then 
DATEDIFF(rr.actual_time,cr.shouldback_time) else null end as  overdue,
DATEDIFF(NOW(),cr.shouldback_time)dq_days
from  bmdb.tb_credit_record cr 
left join 
bmdb.tb_repayment_record rr
on cr.id=rr.credit_id
where cr.shouldback_time is not null and cr.arrive_time>='2017-05-01'
)t
GROUP BY 1 