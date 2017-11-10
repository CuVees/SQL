DELIMITER $$
CREATE FUNCTION reportdb.func_report_refuse_info(idate date)  # 创建函数
RETURNS TINYINT   
BEGIN  
#############选出数据####插入reportdb.risk_pass_uid表中###### 
delete from reportdb.risk_pass_uid;
insert into reportdb.risk_pass_uid(uid)

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

union all

-- 米信拒绝用户——在米乐未结清或者逾期
SELECT uid
from 
(SELECT 
case when EXISTS (select 1 from mldb.tb_credit_record t 
where t.tel=cr.tel) then 1 else 0 end as is_mfsq,

case when EXISTS (select 1 from mldb.tb_credit_record t 
where t.tel=cr.tel  and t.status in (3,5,6,7,8) and t.created_time<cr.created_time) then 1 else 0 end as is_mffk,

case when EXISTS (select 1 from mldb.tb_credit_record t 
where t.tel=cr.tel  and t.status in (6,7,8) and t.created_time<cr.created_time) then 1 else 0 end as is_mfbl,


case when EXISTS (select 1 from mldb.tb_credit_record t  left join 
mldb.tb_repayment_record rr
on t.id=rr.credit_id
where t.tel=cr.tel  and t.shouldback_time is not null  and t.created_time<cr.created_time and (rr.actual_time is null or  rr.actual_time>cr.created_time) ) then 1 else 0 end as is_mfzt ,

case when EXISTS (select 1 from mldb.tb_credit_record t  left join 
mldb.tb_repayment_record rr
on t.id=rr.credit_id
where t.tel=cr.tel  and t.shouldback_time<cr.created_time  and t.created_time<cr.created_time and (rr.actual_time is null or rr.actual_time>cr.created_time) ) then 1 else 0 end as is_mfyq ,

cr.*
from 
msdb.tb_credit_record cr 
where cr.`status` in (1,2)
)t
where t.is_mfyq=1 or t.is_mfbl=1

union all

-- 米乐米信拒绝用户-在米发未结清或逾期
SELECT uid
from 
(SELECT 
case when EXISTS (select 1 from bmdb.tb_credit_record t 
where t.tel=cr.tel) then 1 else 0 end as is_mfsq,

case when EXISTS (select 1 from bmdb.tb_credit_record t 
where t.tel=cr.tel  and t.status in (3,5,6,7,8) and t.created_time<cr.created_time) then 1 else 0 end as is_mffk,

case when EXISTS (select 1 from bmdb.tb_credit_record t 
where t.tel=cr.tel  and t.status in (6,7,8) and t.created_time<cr.created_time) then 1 else 0 end as is_mfbl,


case when EXISTS (select 1 from bmdb.tb_credit_record t  left join 
bmdb.tb_repayment_record rr
on t.id=rr.credit_id
where t.tel=cr.tel  and t.shouldback_time is not null  and t.created_time<cr.created_time and (rr.actual_time is null or  rr.actual_time>cr.created_time) ) then 1 else 0 end as is_mfzt ,

case when EXISTS (select 1 from bmdb.tb_credit_record t  left join 
bmdb.tb_repayment_record rr
on t.id=rr.credit_id
where t.tel=cr.tel  and t.shouldback_time<cr.created_time  and t.created_time<cr.created_time and (rr.actual_time is null or rr.actual_time>cr.created_time) ) then 1 else 0 end as is_mfyq ,

cr.*
from 
mldb.tb_credit_record cr 
where cr.`status` in (1,2)
)t
where t.is_mfyq=1 or t.is_mfbl=1

union all

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



########设置状态#####改为通过#####
 UPDATE bmdb.tb_credit_record a set status=12,audit_time=now() 
 WHERE a.uid in(SELECT uid from reportdb.risk_pass_uid) and status in (1,2);

#############备份数据############
insert into reportdb.risk_pass_uid_backups(uid,inserttime)
SELECT * from reportdb.risk_pass_uid;

#############选出数据####插入reportdb.risk_refuse_uid表中###### 
delete from reportdb.risk_refuse_uid;
insert into reportdb.risk_refuse_uid(uid)
select
uid from 
(
SELECT 
cr.id,kk.maxoverdue,kk.minoverdue,
cr.uid,cr.created_time,cr.arrive_time,cr.status,
cr.shouldback_time,rr.actual_time,
case when cr.shouldback_time<now() and rr.actual_time is null then DATEDIFF(now(),cr.shouldback_time)
when rr.actual_time is not null then 
DATEDIFF(rr.actual_time,cr.shouldback_time) else null end as  overdue
from 
bmdb.tb_credit_record cr 
left join 
bmdb.tb_repayment_record rr
on cr.id=rr.credit_id
left join 
(select t.uid,max(overdue)maxoverdue,min(overdue)minoverdue
from 
(
SELECT 
cr.id,
cr.uid,
case when cr.shouldback_time<now() and rr.actual_time is null then DATEDIFF(now(),cr.shouldback_time)
when rr.actual_time is not null then 
DATEDIFF(rr.actual_time,cr.shouldback_time) else null end as  overdue
from 
bmdb.tb_credit_record cr 
left join 
bmdb.tb_repayment_record rr
on cr.id=rr.credit_id
)t
GROUP BY 1
)kk
on kk.uid=cr.uid

where cr.`status`=1
and cr.task_status=4
and (maxoverdue>=15 or minoverdue>=5)
)t;
########设置状态#####改为拒绝#####
UPDATE bmdb.tb_credit_record a set status=12,audit_time=now() 
WHERE a.uid in(SELECT uid from reportdb.risk_refuse_uid) and status=1;

##################加灰名单##########################
UPDATE bmdb.tb_blacklist c INNER JOIN reportdb.risk_refuse_uid u ON c.uid=u.uid 
SET c.update_time=NOW(),c.STATUS=1;

#############备份数据############
insert into reportdb.risk_refuse_uid_backups(uid,inserttime)
SELECT * from reportdb.risk_refuse_uid;
  RETURN 1;  
END $$
DELIMITER ;