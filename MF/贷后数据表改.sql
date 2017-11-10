SELECT 
a.operator
,a.fengpei_cn
,b.huishou_cnt
,b.huishou_amount
,b.overdue_amount
FROM
(
SELECT operator,operator_id,count(DISTINCT credit_id) as fengpei_cn from tb_overdue_flow_record 
where update_time>='2017-09-01' group by 1,2
) a left join
(
 SELECT
 t1.operator
 ,t1.owner_id
 ,COUNT(t1.credit_id) as huishou_cnt
 ,COUNT(DISTINCT t1.credit_id) 
 ,sum(t2.actual_fee) as huishou_amount
 ,sum(t2.overdue_fee) as overdue_amount
 FROM
 (
  select
  a.operator
  ,a.owner_id
  ,a.credit_id
  from
  (
  SELECT operator,owner_id,credit_id from tb_overdue_record where shouldback_time>='2017-08-31'
  group by 1,2,3
  )a left join
  (
  select id as credit_id from tb_credit_record where status=7 and shouldback_time>='2017-08-31'
  )b on a.credit_id=b.credit_id
  where  b.credit_id is not null 
  group by 1,2,3
 ) t1 left JOIN
 (
 SELECT actual_fee,overdue_fee,credit_id from tb_repayment_record 
 where normal_time>='2017-08-31' and normal_time<'2017-09-21'
 GROUP BY 1,2,3
 )t2 on t1.credit_id=t2.credit_id
 GROUP BY 1,2
)b on a.operator_id=b.owner_id