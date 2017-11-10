BEGIN
	#Routine body goes here...
DELIMITER $$
CREATE FUNCTION reportdb.func_report_refuse(idate date)  # 创建函数
RETURNS TINYINT   
BEGIN  
#############选出数据####插入reportdb.risk_refuse_uid_ml表中###### 
delete from reportdb.risk_refuse_uid_ml;
insert into reportdb.risk_refuse_uid_ml(uid)


##　米乐拒绝用户-在米发未结清或者逾期


## 米乐米信拒绝用户-在米发未结清或逾期
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

## 米乐拒绝用户—在米信未结清或者逾期

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




########设置状态#####改为自动审核失败#####
 #UPDATE mldb.tb_credit_record a set status=12,audit_time=now() 
 #WHERE a.uid in(SELECT uid from reportdb.risk_refuse_uid_ml) and status in (1,2);

#############备份数据############
# insert into reportdb.risk_pass_uid_backups(uid,inserttime)
# SELECT * from reportdb.risk_refuse_uid_ml;



#############选出数据####插入reportdb.risk_refuse_uid_ms表中###### 
delete from reportdb.risk_refuse_uid_ms;
insert into reportdb.risk_refuse_uid_ms(uid)

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
msdb.tb_credit_record cr 
where cr.`status` in (1,2)
)t
where t.is_mfyq=1 or t.is_mfbl=1


########设置状态#####改为自动审核失败#####
#UPDATE msdb.tb_credit_record a set status=12,audit_time=now() 
#WHERE a.uid in(SELECT uid from reportdb.risk_refuse_uid_ms) and status　in (1,2);

#############备份数据############
#insert into reportdb.risk_refuse_uid_backups(uid,inserttime)
#SELECT * from reportdb.risk_refuse_uid_ms;
RETURN 1;  
END