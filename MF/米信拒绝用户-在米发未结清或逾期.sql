-- 米乐拒绝用户—在米信未结清或者逾期

SELECT uid
from 
(SELECT 
case when EXISTS (select 1 from msdb.tb_credit_record t 
where t.tel=cr.tel) then 1 else 0 end as is_mfsq,

case when EXISTS (select 1 from msdb.tb_credit_record t 
where t.tel=cr.tel  and t.status in (3,5,6,7,8) and t.created_time<cr.created_time) then 1 else 0 end as is_mffk,

case when EXISTS (select 1 from msdb.tb_credit_record t 
where t.tel=cr.tel  and t.status in (6,7,8) and t.created_time<cr.created_time) then 1 else 0 end as is_mfbl,


case when EXISTS (select 1 from msdb.tb_credit_record t  left join 
msdb.tb_repayment_record rr
on t.id=rr.credit_id
where t.tel=cr.tel  and t.shouldback_time is not null  and t.created_time<cr.created_time and (rr.actual_time is null or  rr.actual_time>cr.created_time) ) then 1 else 0 end as is_mfzt ,

case when EXISTS (select 1 from msdb.tb_credit_record t  left join 
msdb.tb_repayment_record rr
on t.id=rr.credit_id
where t.tel=cr.tel  and t.shouldback_time<cr.created_time  and t.created_time<cr.created_time and (rr.actual_time is null or rr.actual_time>cr.created_time) ) then 1 else 0 end as is_mfyq ,

cr.*
from 
mldb.tb_credit_record cr 
where cr.`status` in (1,2)
)t
where t.is_mfyq=1 or t.is_mfbl=1

