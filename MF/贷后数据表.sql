select
DATE_FORMAT(a.shouldback_day,'%Y-%m-%d') as  '应还日期'
 ,(a.shouldback_cnt-a.pre_repay_cnt-a.normal_repay_cnt)*1.0/a.shouldback_cnt as '首逾率'
 ,a.pre_repay_cnt*1.0/a.shouldback_cnt  as '提前还款率'
 ,a.normal_repay_cnt*1.0/a.shouldback_cnt  as '当日还款率'
 ,a.overdue_repay_cnt*1.0/a.shouldback_cnt  as  '逾期还款率'
 ,a.untill_overdue_cnt*1.0/a.shouldback_cnt  as '逾期率'
 from
 (
    select  t1.day_key as shouldback_day 
    ,count(distinct t1.id) as shouldback_cnt 
    ,count(distinct case when is_front='1' then t2.credit_id else null end) as pre_repay_cnt 
    ,count(distinct case when is_front='0' then t2.credit_id else null end) as normal_repay_cnt 
    ,count(distinct case when is_front='-1' then t1.id else null end) as overdue_repay_cnt 
    ,count(distinct case when t1.status in(6,8) then t1.id else null end) as untill_overdue_cnt 
   ,(case when product_id in(1,3,5,7) then '7天' when  product_id in(2,4,6,8) then '14天' else 0 end) as type
    from  
    ( select date(shouldback_time) as day_key ,product_id 
        ,id,uid,status from  bmdb.tb_credit_record 
        where $__timeFilter(shouldback_time)   and cycle in($product_type)   group by 1,2,3 
    )t1 left  join 
    (select credit_id,(case when date(normal_time) > date(actual_time) then '1' 
        when date(normal_time) = date(actual_time) then '0' 
        when date(normal_time) < date(actual_time) then '-1' end ) as is_front 
        from  bmdb.tb_repayment_record group by 1,2 
    )t2  on t1.id=t2.credit_id  
   group by t1.day_key
)a group by 1