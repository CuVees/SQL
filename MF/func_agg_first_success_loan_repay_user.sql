BEGIN
delete from reportdb.agg_first_success_loan_repay_user;
insert into reportdb.agg_first_success_loan_repay_user(user_id,credit_id,created_time,status);
select 
t1.uid as user_id,
t1.id as credit_id,
t1.created_time as created_time,
t1.status as status
from(
	select uid,id,created_time,status from (
		select uid,id,created_time,status from bmdb.tb_credit_record where status in (5,7) order by created_time asc
	) a group by uid
) t1 
left join (
	select user_id from reportdb.agg_first_success_loan_repay_user where created_time<idate
) t2
on t1.uid=t2.user_id
where t2.user_id is null;
return 1;
END