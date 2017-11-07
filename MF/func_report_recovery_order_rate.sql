BEGIN  
delete from reportdb.report_recovery_order_rate where day_key=idate ;
insert into reportdb.report_recovery_order_rate(day_key,should_back_cnt,front_repay,normal_repay,overdue_repay,untill_overdue)
select  
  idate
  #,t1.type as type
  ,count(distinct t1.id) as should_back_cnt
  ,count(distinct case when is_front='1' then t2.credit_id else null end) as front_repay
  ,count(distinct case when is_front='0' then t2.credit_id else null end) as normal_repay
  #,count(distinct case when t1.status=5    then t1.id else null end) as repay_new
  ,count(distinct case when is_front='-1' then t1.id else null end) as overdue_repay
  #,count(distinct case when t1.status=7    then t1.id else null end) as overdue_repay_new
  #,count(distinct case when t2.credit_id  is null  then t1.id else null end) as untill_overdue
  ,count(distinct case when t1.status in(6,8)  then t1.id else null end) as untill_overdue
  from  
    (
      select 
      #date(shouldback_time) as day_key
      #,(case when product_id in(1,3) then '7天' when  product_id in(2,4) then '14天' else 0 end) as type
      id
      ,status
      from  bmdb.tb_credit_record 
      where date(shouldback_time)>=date_sub(date_sub(date_format(date_sub(date(now()),interval 1 day),'%y-%m-%d'),interval extract(day from date_sub(date(now()),interval 1 day)) day),interval 0 month)
      and date(shouldback_time) < idate
      #and product_id in(1,3)
      group by 1,2
    )t1 left  join
    (
      select 
      credit_id
      ,(case when date(normal_time) > date(actual_time) then '1' 
      when date(normal_time) = date(actual_time) then '0' 
      when date(normal_time) < date(actual_time) then '-1' end ) as is_front
      from  bmdb.tb_repayment_record 
      group by 1,2
    )t2  on t1.id=t2.credit_id;
  RETURN 1;  
END