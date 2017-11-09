select
  UNIX_TIMESTAMP(shouldback_day) as time_sec
 ,sum((a.shouldback_cnt-a.pre_repay_cnt-a.normal_repay_cnt))*1.0/sum(a.shouldback_cnt) as value
 ,'首逾率' as metric
 from
 (
    select  t1.day_key as shouldback_day 
    ,count(distinct t1.id) as shouldback_cnt 
    ,count(distinct case when is_front='1' then t2.credit_id else null end) as pre_repay_cnt 
    ,count(distinct case when is_front='0' then t2.credit_id else null end) as normal_repay_cnt 
    ,count(distinct case when is_front='-1' then t1.id else null end) as overdue_repay_cnt 
    ,count(distinct case when t1.status in(6,8) then t1.id else null end) as untill_overdue_cnt 
    from  
    ( select shouldback_time as day_key 
        ,id,uid,status from  bmdb.tb_credit_record 
        where $__timeFilter(shouldback_time) and cycle in($product_type)    group by 1,2,3 
    )t1 left  join 
    (select credit_id,(case when date(normal_time) > date(actual_time) then '1' 
        when date(normal_time) = date(actual_time) then '0' 
        when date(normal_time) < date(actual_time) then '-1' end ) as is_front 
        from  bmdb.tb_repayment_record group by 1,2 
    )t2  on t1.id=t2.credit_id  where t1.day_key <=CURRENT_DATE group by t1.day_key
)a GROUP BY metric,date(shouldback_day) 

 ############################################################################################################

 select
  UNIX_TIMESTAMP(shouldback_day) as time_sec
 ,sum(a.pre_repay_cnt)*1.0/sum(a.shouldback_cnt) as value
 ,'提前还款率' as metric
 from
 (
    select  t1.day_key as shouldback_day 
    ,count(distinct t1.id) as shouldback_cnt 
    ,count(distinct case when is_front='1' then t2.credit_id else null end) as pre_repay_cnt 
    ,count(distinct case when is_front='0' then t2.credit_id else null end) as normal_repay_cnt 
    ,count(distinct case when is_front='-1' then t1.id else null end) as overdue_repay_cnt 
    ,count(distinct case when t1.status in(6,8) then t1.id else null end) as untill_overdue_cnt 
    from  
    ( select shouldback_time as day_key 
        ,id,uid,status from  bmdb.tb_credit_record 
        where $__timeFilter(shouldback_time)  and cycle in($product_type)   group by 1,2,3 
    )t1 left  join 
    (select credit_id,(case when date(normal_time) > date(actual_time) then '1' 
        when date(normal_time) = date(actual_time) then '0' 
        when date(normal_time) < date(actual_time) then '-1' end ) as is_front 
        from  bmdb.tb_repayment_record group by 1,2 
    )t2  on t1.id=t2.credit_id  where t1.day_key <=CURRENT_DATE group by t1.day_key
)a GROUP BY metric,date(shouldback_day) 

 ##########################################################################################################################

 select
  UNIX_TIMESTAMP(shouldback_day) as time_sec
 ,sum(a.normal_repay_cnt)*1.0/sum(a.shouldback_cnt) as value
 ,'当日还款率' as metric
 from
 (
    select  t1.day_key as shouldback_day 
    ,count(distinct t1.id) as shouldback_cnt 
    ,count(distinct case when is_front='1' then t2.credit_id else null end) as pre_repay_cnt 
    ,count(distinct case when is_front='0' then t2.credit_id else null end) as normal_repay_cnt 
    ,count(distinct case when is_front='-1' then t1.id else null end) as overdue_repay_cnt 
    ,count(distinct case when t1.status in(6,8) then t1.id else null end) as untill_overdue_cnt 
    from  
    ( select shouldback_time as day_key 
        ,id,uid,status from  bmdb.tb_credit_record 
        where $__timeFilter(shouldback_time)  and cycle in($product_type)   group by 1,2,3 
    )t1 left  join 
    (select credit_id,(case when date(normal_time) > date(actual_time) then '1' 
        when date(normal_time) = date(actual_time) then '0' 
        when date(normal_time) < date(actual_time) then '-1' end ) as is_front 
        from  bmdb.tb_repayment_record group by 1,2 
    )t2  on t1.id=t2.credit_id  where t1.day_key <=CURRENT_DATE group by t1.day_key
)a GROUP BY metric,date(shouldback_day) 


 ###########################################################################################

 select
  UNIX_TIMESTAMP(shouldback_day) as time_sec
 ,sum(a.overdue_repay_cnt)*1.0/sum(a.shouldback_cnt) as value
 ,'逾期还款率' as metric
 from
 (
    select  t1.day_key as shouldback_day 
    ,count(distinct t1.id) as shouldback_cnt 
    ,count(distinct case when is_front='1' then t2.credit_id else null end) as pre_repay_cnt 
    ,count(distinct case when is_front='0' then t2.credit_id else null end) as normal_repay_cnt 
    ,count(distinct case when is_front='-1' then t1.id else null end) as overdue_repay_cnt 
    ,count(distinct case when t1.status in(6,8) then t1.id else null end) as untill_overdue_cnt 
    from  
    ( select shouldback_time as day_key 
        ,id,uid,status from  bmdb.tb_credit_record 
        where $__timeFilter(shouldback_time)  and cycle in($product_type)    group by 1,2,3 
    )t1 left  join 
    (select credit_id,(case when date(normal_time) > date(actual_time) then '1' 
        when date(normal_time) = date(actual_time) then '0' 
        when date(normal_time) < date(actual_time) then '-1' end ) as is_front 
        from  bmdb.tb_repayment_record group by 1,2 
    )t2  on t1.id=t2.credit_id  where t1.day_key <=CURRENT_DATE group by t1.day_key
)a GROUP BY metric,date(shouldback_day) 


#############################################################################################################

 select
  UNIX_TIMESTAMP(shouldback_day) as time_sec
 ,sum(a.untill_overdue_cnt)*1.0/sum(a.shouldback_cnt) as value
 ,'逾期率' as metric
 from
 (
    select  t1.day_key as shouldback_day 
    ,count(distinct t1.id) as shouldback_cnt 
    ,count(distinct case when is_front='1' then t2.credit_id else null end) as pre_repay_cnt 
    ,count(distinct case when is_front='0' then t2.credit_id else null end) as normal_repay_cnt 
    ,count(distinct case when is_front='-1' then t1.id else null end) as overdue_repay_cnt 
    ,count(distinct case when t1.status in(6,8) then t1.id else null end) as untill_overdue_cnt 
    from  
    ( select shouldback_time as day_key 
        ,id,uid,status from  bmdb.tb_credit_record 
        where $__timeFilter(shouldback_time)  and cycle in($product_type)   group by 1,2,3 
    )t1 left  join 
    (select credit_id,(case when date(normal_time) > date(actual_time) then '1' 
        when date(normal_time) = date(actual_time) then '0' 
        when date(normal_time) < date(actual_time) then '-1' end ) as is_front 
        from  bmdb.tb_repayment_record group by 1,2 
    )t2  on t1.id=t2.credit_id  where t1.day_key <=CURRENT_DATE group by t1.day_key
)a GROUP BY metric,date(shouldback_day) 
