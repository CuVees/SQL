BEGIN  
delete from reportdb.report_order_count where day_key=idate ;
insert into  reportdb.report_order_count(day_key,order_cnt ,effective_order_cnt ,same_day_submit_cnt,same_day_lv ,other_day_submit_cnt,past_lv,auto_refuse_cnt 
    ,auto_refuse_lv,atuo_pass_cnt ,atuo_pass_lv ,manual_cnt ,manual_lv,manual_pass_cnt ,manual_refuse_cnt ,manual_pass_lv ,pass_all_cnt ,pass_all_lv)
select
a.day_key
,a.order_cnt
,a.effective_order_cnt 
,a.same_day_submit_cnt
,COALESCE(a.same_day_submit_cnt*1.0/a.order_cnt,0) as same_day_lv
,a.other_day_submit_cnt
,COALESCE(a.other_day_submit_cnt*1.0/a.order_cnt,0) as past_lv
,a.auto_refuse_cnt
,COALESCE(a.auto_refuse_cnt*1.0/a.effective_order_cnt,0)as auto_refuse_lv
,a.atuo_pass_cnt
,COALESCE(a.atuo_pass_cnt*1.0/a.effective_order_cnt,0) as atuo_pass_lv
,a.manual_cnt
,COALESCE(a.manual_cnt*1.0/a.effective_order_cnt,0) as manual_lv
,a.manual_pass_cnt
,a.manual_refuse_cnt
,COALESCE(a.manual_pass_cnt*1.0/(a.manual_pass_cnt+a.manual_refuse_cnt),0) as manual_pass_lv
,a.pass_all_cnt
,COALESCE(a.pass_all_cnt*1.0/a.effective_order_cnt,0)as pass_all_lv
from
(
    SELECT
    t1.day_key as day_key
    ,count(t1.id) as order_cnt
    ,count(case when t2.id is not null then t1.id end) as same_day_submit_cnt
    ,count(case when t2.id is null then t1.id end) as other_day_submit_cnt
    ,count(case when t1.status=12 then t1.id end) as auto_refuse_cnt
    ,count(case when (manager_name is  NULL or  manager_name='') and status in(2,3,5,6,7,8,9,10) then t1.id end) as atuo_pass_cnt
    ,count(case when(manager_name IS NOT NULL and  manager_name!='' and status in(2,3,4,5,6,7,8,9,10))or status=1 then t1.id end) as manual_cnt
    ,count(case when manager_name IS NOT NULL and  manager_name!='' and status in(2,3,5,6,7,8,9,10) then t1.id end) as manual_pass_cnt
    ,count(case when status=4 then t1.id end) as manual_refuse_cnt
    ,count(case when status in(2,3,5,6,7,8,9,10) then t1.id end) as pass_all_cnt
    ,(count(t1.id)-COUNT(case when t3.credit_id is not null then t1.id end)) as effective_order_cnt
    FROM
    (
    SELECT 
    date(created_time) as day_key
    ,id
    ,uid
    ,status
    ,manager_name
    from bmdb.tb_credit_record 
    where created_time>=idate and created_time<date_add(idate,INTERVAL 1 DAY)
    GROUP BY 1,2,3,4,5
    )t1 left JOIN
    (
    select 
    date(created) as day_key
    ,id 
    from bmdb.tb_user where created>=idate and created<date_add(idate,INTERVAL 1 DAY)
    group by 1,2
    )t2 on t1.uid=t2.id and t2.day_key=t1.day_key left join
    (
    SELECT credit_id from bmdb.tb_score_rule_result where status = 1 and risk_type  LIKE 'N%'  GROUP BY 1
    )t3 on t1.id=t3.credit_id
    group by 1
)a;

  RETURN 1;  
END