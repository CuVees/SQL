BEGIN  
 delete from reportdb.report_overdue_order_day where day_key>=date_sub(idate,INTERVAL 31 DAY) ;
insert into  reportdb.report_overdue_order_day(day_key,day1,day3,day7,day15,day30,arrive_cnt,arrive_amount)
select
  t1.created_day as day_key,
  count(DISTINCT CASE WHEN t2.days >=1  THEN t2.id ELSE null END) day1,
  count(DISTINCT CASE WHEN t2.days >=3  THEN t2.id ELSE null END) day3,
  count(DISTINCT CASE WHEN t2.days >=7  THEN t2.id ELSE null END) day7,
  count(DISTINCT CASE WHEN t2.days >=15 THEN t2.id ELSE null END) day15,
  count(DISTINCT CASE WHEN t2.days >=30 THEN t2.id ELSE null END) day30,
  COALESCE(t3.arrive_cnt,0) as arrive_cnt ,
  COALESCE(t3.arrive_amount,0) as arrive_amount
from 
(
  select day_key  as created_day
  from  reportdb.report_partner_effect 
  WHERE  day_key>=date_sub(idate,INTERVAL 31 DAY) and day_key<date_add(idate,INTERVAL 1 DAY)
)t1 left JOIN
(
 select
  id
  ,DATE_FORMAT(arrive_time, '%Y-%m-%d') as arrive_day
  ,datediff(now(), shouldback_time) days
  ,actual_balance
  from  bmdb.tb_credit_record WHERE STATUS in(6,8)
  and DATE_FORMAT(arrive_time, '%Y-%m-%d')>=date_sub(idate,INTERVAL 61 DAY) 
  and DATE_FORMAT(arrive_time, '%Y-%m-%d')<date_add(idate,INTERVAL 1 DAY)
  group by 1,2,3,4
)t2 on t1.created_day=t2.arrive_day left join
(
  select 
  DATE_FORMAT(arrive_time, '%Y-%m-%d') as arrive_day
  ,count(id) as arrive_cnt
  ,sum(actual_balance) as arrive_amount
  from  bmdb.tb_credit_record 
  where DATE_FORMAT(arrive_time, '%Y-%m-%d')>=date_sub(idate,INTERVAL 61 DAY) 
  and DATE_FORMAT(arrive_time, '%Y-%m-%d')<date_add(idate,INTERVAL 1 DAY)
  group by 1
)t3 on t1.created_day=t3.arrive_day
group by 1,7,8
ORDER BY 1 desc;

  RETURN 1;  
END