BEGIN  
#############选出数据####插入reportdb.risk_pass_uid表中###### 
delete from reportdb.risk_pass_uid;
insert into reportdb.risk_pass_uid(uid)
select uid from 
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
where cr.status=1
and cr.task_status=4
and (maxoverdue<=2 or minoverdue<=0)
)t
UNION 
SELECT 
cr.uid
from 
bmdb.tb_credit_record cr 
left join 
bmdb.tb_repayment_record rr
on cr.id=rr.credit_id
LEFT JOIN 
bmdb.tb_zhima_credit_record zcr 
on cr.id=zcr.credit_id
where cr.status=1
and ((cr.task_status=2 and zcr.zm_score>630) or (cr.task_status=3 and zcr.zm_score>660));

########设置状态#####改为通过#####
UPDATE bmdb.tb_credit_record a set status=2,audit_time=now() 
WHERE a.uid in(SELECT uid from reportdb.risk_pass_uid) and status=1;

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
END