BEGIN  
delete from reportdb.report_partner_effect where day_key>=date_sub(idate, INTERVAL 8 DAY);
insert into  reportdb.report_partner_effect
(day_key,partner_no,partner_name,reg_cnt,real_name,submit_order_cnt,suc_order_cnt,suc_order_amount,overdue_amount,partner_type,alias_name,uv_count)
select 
t1.day_key as day_key
,t1.partner_no as partner_no
,t1.partner_name as partner_name
,count(t1.user_id) as reg_cnt
,count(t2.uid)     as real_name
,count(t3.id)      as submit_order_cnt
,count(case when t3.status in(3,5,6,7,8) then t3.id else null end)   as suc_order_cnt
,sum(case when t3.status in(3,5,6,7,8) then t3.actual_balance else 0 end)   as suc_order_amount
,sum(case when t3.status in(6,8) then t3.actual_balance else 0 end)   as overdue_amount
,t1.partner_type as partner_type
,t1.alias_name as alias_name
,t4.uv_count as uv_count
from
(

    select 
    a1.day_key
    ,a1.user_id
    ,a1.partner_no
    ,a2.partner_name
    ,a2.partner_type
    ,a1.alias_name
    FROM
    (
      select 
      DATE(created) as day_key
      ,user_id
      ,partner_no
      ,alias_name
      from bmdb.tb_user_phone_adapter 
      where DATE(created)>=date_sub(idate, INTERVAL 8 DAY) and DATE(created)<date_add(idate, INTERVAL 1 DAY)
      and partner_no<>'200094?' and partner_no<>'undefined'
      group by DATE(created) ,user_id,partner_no,alias_name
    )a1 left join

    (
      select 
      partner_no
      ,partner_name
      ,partner_type
      from bmdb.tb_partner 
      group by partner_no,partner_name
    )a2 on a1.partner_no=a2.partner_no
    group by a1.day_key,a1.user_id,a1.partner_no,a2.partner_name,a2.partner_type,a1.alias_name
)t1 left join

(
    select 
    uid 
    from bmdb.tb_shiming_record 
    where  date(create_time)>=date_sub(idate, INTERVAL 8 DAY)  and date(create_time)<date_add(idate, INTERVAL 1 DAY)
    group by uid 
)t2 on t1.user_id=t2.uid left join
(
    select
    uid 
    ,id 
    ,status
    ,actual_balance
    ,balance
    from 
    (
    select uid,id,actual_balance,status,balance from  bmdb.tb_credit_record 
    where  date(created_time)>=date_sub(idate, INTERVAL 8 DAY) and  date(created_time)< date_add(idate, INTERVAL 1 DAY)
    order by  created_time asc 
    )a  GROUP BY  uid 
)t3 on t1.user_id=t3.uid left join
(
select date(update_time) as day_key
,param2 as partner_no
,param3 as alias_name
,1 as partner_type
,sum(uv_count) as uv_count
from bmdb.tb_visit_record 
where date(update_time)>=date_sub(idate, INTERVAL 8 DAY) and  date(update_time)< date_add(idate, INTERVAL 1 DAY)
group by 1,2
)t4 on t1.partner_no=t4.partner_no and  t1.day_key=t4.day_key and t4.alias_name=t1.alias_name and t4.partner_type=t1.partner_type
group by t1.day_key,t1.partner_no,t1.partner_name,t1.partner_type,t1.alias_name,t4.uv_count;


  RETURN 1;  
END