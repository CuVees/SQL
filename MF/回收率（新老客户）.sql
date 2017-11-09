select 
UNIX_TIMESTAMP(t.shouldback_time) as time_sec,
sum(case when dq_days>0 AND overdue>=15 then 1 else 0 end)/sum(case when dq_days>=15 then 1 else 0 end) as value,
'逾期十五天' as metric
from 
(
SELECT 
cr.id,
cr.shouldback_time,rr.actual_time,
case when cr.shouldback_time<now() and rr.actual_time is null then DATEDIFF(now(),cr.shouldback_time)
when rr.actual_time is not null then 
DATEDIFF(rr.actual_time,cr.shouldback_time) else null end as  overdue,
DATEDIFF(NOW(),cr.shouldback_time)dq_days
from 
bmdb.tb_credit_record cr 
left join 
bmdb.tb_repayment_record rr
on cr.id=rr.credit_id
where cr.shouldback_time is not null and $__timeFilter(cr.shouldback_time) 
)t
GROUP BY metric,date(t.shouldback_time) 
