BEGIN
 delete from reportdb.report_old_user_re_cast where day_key=idate ;
insert into  reportdb.report_old_user_re_cast(day_key,old_cnt,submit_cnt,re_cast_lv)
select 
idate
,count(distinct t1.user_id) as old_cnt
,count(distinct t2.uid ) as submit_cnt
,round(count(distinct t2.uid )*1.0/count(distinct t1.user_id),6) as re_cast_lv
from 
(
	select date(created_time) as day_key,user_id,credit_id 
	from reportdb.agg_first_success_loan_repay_user
	where date(created_time)<idate
)t1 left join
(
	select 
	date(created_time) as day_key
	,id
	,uid
	,status
	from  bmdb.tb_credit_record 
	where date(created_time)=idate
	group by 1,2,3,4
)t2 on t2.uid=t1.user_id;

  RETURN 1;  
END